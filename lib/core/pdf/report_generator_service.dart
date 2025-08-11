// lib/core/report_generator_service.dart

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluator.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/http/models/Problem.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_core/theme.dart';

// Modelo de dados para os gráficos
class _ChartData {
  _ChartData(this.category, this.value, [this.color]);
  final String category;
  final num value;
  final Color? color;
}

class ReportGeneratorService {
  // --- MÉTODOS PRINCIPAIS (sem alteração) ---
  static Future<void> generateEvaluatorReport({
    required BuildContext context,
    required Evaluator evaluator,
    required Evaluation evaluation,
    required List<Objective> objectives,
    required List<Problem> problems,
  }) async {
    await _generateAndShowPdf(
      context: context,
      evaluation: evaluation,
      objectives: objectives,
      problems: problems,
      evaluator: evaluator,
      isConsolidated: false,
    );
  }

  static Future<void> generateConsolidatedReport({
    required BuildContext context,
    required Evaluation evaluation,
    required List<Objective> objectives,
    required List<Evaluator> evaluators,
    required Map<int, List<Problem>> problemsByEvaluator,
  }) async {
    final allProblems =
    problemsByEvaluator.values.expand((list) => list).toList();
    if (allProblems.isEmpty) return;

    await _generateAndShowPdf(
      context: context,
      evaluation: evaluation,
      objectives: objectives,
      problems: allProblems,
      isConsolidated: true,
    );
  }

  // --- Método central que constrói e exibe o PDF ---
  static Future<void> _generateAndShowPdf({
    required BuildContext context,
    required Evaluation evaluation,
    required List<Objective> objectives,
    required List<Problem> problems,
    required bool isConsolidated,
    Evaluator? evaluator,
  }) async {
    final heuristicData = _processHeuristicData(problems);
    final severityData = _processSeverityData(problems);

    final pieChartBytes = await _generatePieChart(context, severityData);
    final barChartBytes = await _generateBarChart(context, heuristicData);

    final pdf = pw.Document();
    final font = await PdfGoogleFonts.latoRegular();
    final fontBold = await PdfGoogleFonts.latoBold();
    pw.MemoryImage? logoImage;
    try {
      logoImage = pw.MemoryImage((await rootBundle
          .load('assets/images/logo_app_bar.png'))
          .buffer
          .asUint8List());
    } catch (_) {
      logoImage = null;
    }

    // --- LAYOUT RESTAURADO: Borda principal da página ---
    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      buildBackground: (pw.Context context) => pw.FullPage(
        ignoreMargins: true,
        child: pw.Container(
          margin: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 1.5),
          ),
        ),
      ),
      theme: pw.ThemeData.withFont(
        base: font,
        bold: fontBold,
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        header: (pw.Context ctx) =>
            _buildHeader(logoImage, evaluation.description ?? 'Título da Avaliação'),
        footer: (pw.Context ctx) => _buildFooter(ctx),
        build: (pw.Context ctx) => [
          _buildInfoBox(evaluation, evaluator),
          _buildObjectivesBox(objectives),
          _buildChartsBox(pieChartBytes, barChartBytes),
          pw.NewPage(),
          ..._buildAllProblemSections(objectives, problems),
        ],
      ),
    );

    final String fileName = isConsolidated
        ? 'Relatorio_Consolidado_${evaluation.description?.replaceAll(' ', '_')}.pdf'
        : 'Relatorio_Individual_${evaluator?.user?.name?.replaceAll(' ', '_')}.pdf';

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: fileName,
    );
  }

  // --- MÉTODOS DE PROCESSAMENTO DE DADOS (sem alteração) ---
  static List<_ChartData> _processHeuristicData(List<Problem> problems) {
    if (problems.isEmpty) return [];
    final counts = <String, int>{};
    for (var problem in problems) {
      final key = problem.heuristic?.description
          ?.split(' ')
          .firstWhere((s) => s.startsWith('(H'), orElse: () => 'N/D')
          .replaceAll(RegExp(r'[\(\)]'), '') ??
          'N/D';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    final sortedEntries = counts.entries.toList()
      ..sort((a, b) {
        final numA = int.tryParse(a.key.substring(1)) ?? 99;
        final numB = int.tryParse(b.key.substring(1)) ?? 99;
        return numA.compareTo(numB);
      });
    return sortedEntries.map((e) => _ChartData(e.key, e.value)).toList();
  }

  static List<_ChartData> _processSeverityData(List<Problem> problems) {
    if (problems.isEmpty) return [];
    final counts = <String, int>{};
    for (var problem in problems) {
      final key = problem.severity?.description ?? 'Não definida';
      counts[key] = (counts[key] ?? 0) + 1;
    }

    final colorMap = {
      'Problema Cosmético': const Color(0xFF000000),
      'Problema Simples': const Color(0xFF555555),
      'Problema Grave': const Color(0xFFAAAAAA),
      'Problema Catastrófico': const Color(0xFFDDDDDD),
    };
    return counts.entries
        .map((e) => _ChartData(e.key, e.value, colorMap[e.key] ?? Colors.grey))
        .toList();
  }

  // --- MÉTODOS DE GERAÇÃO DE GRÁFICOS (sem alteração) ---
  static Future<Uint8List?> _generateBarChart(BuildContext context, List<_ChartData> data) async {
    if (data.isEmpty) return null;
    final SfCartesianChart chart = SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(majorGridLines: const MajorGridLines(width: 0), majorTickLines: const MajorTickLines(size: 0)),
      primaryYAxis: NumericAxis(isVisible: true, minimum: 0, interval: 1, axisLine: const AxisLine(width: 0), majorTickLines: const MajorTickLines(size: 0)),
      series: <CartesianSeries<_ChartData, String>>[
        ColumnSeries<_ChartData, String>(
          dataSource: data,
          xValueMapper: (_ChartData sales, _) => sales.category,
          yValueMapper: (_ChartData sales, _) => sales.value,
          color: const Color(0xFF888888),
          width: 0.6,
          dataLabelSettings: const DataLabelSettings(isVisible: true, labelAlignment: ChartDataLabelAlignment.top, textStyle: TextStyle(fontSize: 10, color: Colors.black)),
        ),
      ],
    );
    return await _exportChartToImage(context, chart, const Size(350, 220));
  }

  static Future<Uint8List?> _generatePieChart(BuildContext context, List<_ChartData> data) async {
    if (data.isEmpty) return null;
    final SfCircularChart chart = SfCircularChart(
      series: <CircularSeries>[
        PieSeries<_ChartData, String>(
          dataSource: data,
          xValueMapper: (_ChartData data, _) => data.category,
          yValueMapper: (_ChartData data, _) => data.value,
          pointColorMapper: (_ChartData data, _) => data.color,
          dataLabelMapper: (data, _) => '${data.category}\n${data.value.toInt()}',
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            textStyle: TextStyle(fontSize: 10, color: Colors.black),
            connectorLineSettings: ConnectorLineSettings(type: ConnectorType.line, length: '10%'),
          ),
          startAngle: -90,
          endAngle: 270,
        ),
      ],
    );
    return await _exportChartToImage(context, chart, const Size(350, 220));
  }

  // --- FUNÇÃO AUXILIAR DE EXPORTAÇÃO (sem alteração) ---
  static Future<Uint8List?> _exportChartToImage(BuildContext context, Widget chart, Size size) async {
    final Completer<Uint8List?> completer = Completer();
    final GlobalKey key = GlobalKey();

    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0, left: 0,
        child: Material(
          color: Colors.transparent,
          child: RepaintBoundary(
            key: key,
            child: Container(
              width: size.width,
              height: size.height,
              child: SfChartTheme(
                data: SfChartThemeData(
                  backgroundColor: Colors.white,
                  titleTextColor: Colors.black,
                  axisLabelColor: Colors.black,
                  legendTextColor: Colors.black,
                  dataLabelTextStyle: const TextStyle(color: Colors.black, fontSize: 10),
                ),
                child: chart,
              ),
            ),
          ),
        ),
      ),
    );

    final overlay = Overlay.of(context);
    overlay.insert(overlayEntry);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final RenderRepaintBoundary boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
        final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        completer.complete(byteData?.buffer.asUint8List());
      } catch (e) {
        completer.completeError(e);
      } finally {
        overlayEntry?.remove();
      }
    });

    return completer.future;
  }

  // --- MÉTODOS DE CONSTRUÇÃO DOS BLOCOS DO PDF (LAYOUT RESTAURADO) ---

  static pw.Widget _buildHeader(pw.MemoryImage? logo, String title) {
    return pw.Container(
      height: 60,
      margin: const pw.EdgeInsets.only(left: 20, right: 20, bottom: 20),
      decoration: const pw.BoxDecoration(color: PdfColors.black),
      child: pw.Stack(
        alignment: pw.Alignment.center,
        children: [
          if (logo != null)
            pw.Positioned(
              left: 10,
              top: 10,
              bottom: 10,
              child: pw.Image(logo),
            ),
          pw.Center(
            child: pw.Text(
              title,
              style: pw.TextStyle(color: PdfColors.white, fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    final formattedDate = DateFormat('dd/MM/yyyy \'às\' HH:mm').format(DateTime.now());
    return pw.Container(
      margin: const pw.EdgeInsets.fromLTRB(30, 20, 30, 15), // Margem ajustada para subir o rodapé
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Gerado em $formattedDate', style: const pw.TextStyle(color: PdfColors.grey, fontSize: 8)),
          pw.Text('@panda', style: const pw.TextStyle(color: PdfColors.grey, fontSize: 8)),
          pw.Text('Página ${context.pageNumber} / ${context.pagesCount}', style: const pw.TextStyle(color: PdfColors.grey, fontSize: 8)),
        ],
      ),
    );
  }

  static pw.Widget _buildTitledBox(String title, pw.Widget child) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.Divider(color: PdfColors.grey, height: 15),
          child,
        ],
      ),
    );
  }

  static pw.Widget _buildInfoBox(Evaluation evaluation, Evaluator? evaluator) {
    pw.Row infoLine(String label, String value) {
      return pw.Row(
        children: [
          pw.SizedBox(width: 80, child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Text(value),
        ],
      );
    }

    return _buildTitledBox('Informações',
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (evaluator != null) infoLine('Avaliador:', evaluator.user?.name ?? 'N/A'),
                  infoLine('Link:', evaluation.link ?? 'N/A'),
                  infoLine('Solicitante:', evaluation.user?.name ?? 'N/A'),
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  infoLine('Data de Início:', DateFormat('dd/MM/yyyy').format(DateTime.parse(evaluation.startDate!))),
                  infoLine('Data Final:', DateFormat('dd/MM/yyyy').format(DateTime.parse(evaluation.finalDate!))),
                ],
              ),
            ),
          ],
        )
    );
  }

  static pw.Widget _buildObjectivesBox(List<Objective> objectives) {
    pw.Widget targetIcon = pw.SizedBox(
      width: 12,
      height: 12,
      child: pw.Stack(
        alignment: pw.Alignment.center,
        children: [
          pw.Container(
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              border: pw.Border.all(color: PdfColors.black, width: 1),
            ),
          ),
          pw.Container(
            width: 6,
            height: 6,
            decoration: const pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    );

    return _buildTitledBox('Objetivos',
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: objectives.map((obj) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Row(
                children: [
                  targetIcon,
                  pw.SizedBox(width: 8),
                  pw.Text(obj.description ?? 'N/A'),
                ]
            ),
          )).toList(),
        )
    );
  }

  static pw.Widget _buildChartsBox(Uint8List? pieChartBytes, Uint8List? barChartBytes) {
    return _buildTitledBox('Gráficos',
        pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(children: [
                  pw.Text('Problemas Identificados', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  if (pieChartBytes != null) pw.Image(pw.MemoryImage(pieChartBytes)),
                ]),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(children: [
                  pw.Text('Heurísticas Violadas', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  if (barChartBytes != null) pw.Image(pw.MemoryImage(barChartBytes)),
                ]),
              ),
            ]
        )
    );
  }

  static List<pw.Widget> _buildAllProblemSections(List<Objective> objectives, List<Problem> allProblems) {
    if (allProblems.isEmpty) {
      return [_buildTitledBox('Avaliação', pw.Text('Nenhum problema de usabilidade foi encontrado nesta avaliação.'))];
    }

    return objectives.map((objective) {
      final objectiveProblems = allProblems.where((p) => p.objective?.id == objective.id).toList();
      if (objectiveProblems.isEmpty) {
        return pw.SizedBox.shrink();
      }
      return _buildTitledBox(
        'Avaliação - ${objective.description}',
        pw.Column(
          children: List.generate(objectiveProblems.length, (index) {
            final problem = objectiveProblems[index];
            return pw.Column(
                children: [
                  if (index > 0) pw.Divider(height: 20),
                  _buildProblemDetailItem(problem, index + 1),
                ]
            );
          }),
        ),
      );
    }).toList();
  }

  static pw.Widget _buildProblemDetailItem(Problem problem, int problemNumber) {
    pw.Padding detailLine(String label, String value) {
      return pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4),
          child: pw.RichText(
              text: pw.TextSpan(
                  children: [
                    pw.TextSpan(text: '$label ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.TextSpan(text: value),
                  ]
              )
          )
      );
    }

    return pw.Container(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Problema $problemNumber', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
            pw.Divider(height: 5, color: PdfColors.grey),
            detailLine('Heurística de Nielsen:', problem.heuristic?.description ?? 'N/A'),
            detailLine('Descrição do Problema:', problem.description ?? 'N/A'),
            detailLine('Recomendação de Melhoria:', problem.recomendation ?? 'N/A'),
            detailLine('Severidade do Problema:', problem.severity?.description ?? 'N/A'),
          ],
        )
    );
  }
}