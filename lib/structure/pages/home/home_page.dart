import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/structure/http/models/DashboardIndicators.dart';
import 'package:flutter_pandyzer/structure/http/models/Log.dart';
import 'package:flutter_pandyzer/structure/pages/home/home_bloc.dart';
import 'package:flutter_pandyzer/structure/pages/home/home_event.dart';
import 'package:flutter_pandyzer/structure/pages/home/home_state.dart';
import 'package:flutter_pandyzer/structure/widgets/app_container.dart';
import 'package:flutter_pandyzer/structure/widgets/app_error.dart';
import 'package:flutter_pandyzer/structure/widgets/app_loading.dart';
import 'package:flutter_pandyzer/structure/widgets/app_sized_box.dart';
import 'package:flutter_pandyzer/structure/widgets/dashboard_card.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../widgets/app_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeBloc _bloc = HomeBloc();
  String? _selectedSection;

  @override
  void initState() {
    super.initState();
    _bloc.add(LoadDataHomeEvent());
  }

  void _onSectionSelected(String section) {
    setState(() {
      _selectedSection = (_selectedSection == section) ? null : section;
    });
  }

  // -------------------- HEADER --------------------
  Widget _header(String userName) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.big),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                appText(
                  text: 'Seja bem-vindo, $userName',
                  fontSize: AppFontSize.fs28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                appSizedBox(height: 6),
                appText(
                  text:
                  'Aqui está um resumo das suas avaliações e atividades recentes.',
                  color: AppColors.grey700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- KPIs (CARDS) --------------------
  Widget _dashboards(DashboardIndicators indicators) {
    const String naoIniciadas = "Avaliações Não Iniciadas";
    const String emAndamento = "Avaliações em Andamento";
    const String concluidas = "Avaliações Concluídas";

    Widget buildCard(
        String title, String value, IconData icon, Color iconColor) {
      return DashboardCard(
        title: title,
        value: value,
        icon: icon,
        iconColor: iconColor,
        isHighlighted: _selectedSection == title,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;

        // >= 1000px: 3 colunas alinhadas
        if (w >= 1000) {
          return Row(
            children: [
              Expanded(
                  child: buildCard(
                      naoIniciadas,
                      indicators.avaliacoesNaoIniciadas.toString(),
                      Icons.play_circle_outline,
                      Colors.grey.shade400)),
              const SizedBox(width: AppSpacing.big),
              Expanded(
                  child: buildCard(
                      emAndamento,
                      indicators.avaliacoesEmAndamento.toString(),
                      Icons.hourglass_bottom_outlined,
                      Colors.grey.shade600)),
              const SizedBox(width: AppSpacing.big),
              Expanded(
                  child: buildCard(
                      concluidas,
                      indicators.avaliacoesConcluidas.toString(),
                      Icons.check_circle_outline,
                      Colors.grey.shade800)),
            ],
          );
        }

        // < 1000px: grid fluido (2 ou 1 por linha)
        return Wrap(
          spacing: AppSpacing.big.toDouble(),
          runSpacing: AppSpacing.big.toDouble(),
          children: [
            SizedBox(
              width: w >= 680 ? (w - AppSpacing.big) / 2 : w,
              child: buildCard(
                  naoIniciadas,
                  indicators.avaliacoesNaoIniciadas.toString(),
                  Icons.play_circle_outline,
                  Colors.grey.shade400),
            ),
            SizedBox(
              width: w >= 680 ? (w - AppSpacing.big) / 2 : w,
              child: buildCard(
                  emAndamento,
                  indicators.avaliacoesEmAndamento.toString(),
                  Icons.hourglass_bottom_outlined,
                  Colors.grey.shade600),
            ),
            SizedBox(
              width: w >= 680 ? (w - AppSpacing.big) / 2 : w,
              child: buildCard(
                  concluidas,
                  indicators.avaliacoesConcluidas.toString(),
                  Icons.check_circle_outline,
                  Colors.grey.shade800),
            ),
          ],
        );
      },
    );
  }

  // -------------------- GRÁFICO (DOUGHNUT) --------------------
  Widget _buildStatusChart(DashboardIndicators indicators, double maxWidth) {
    final total = indicators.avaliacoesNaoIniciadas +
        indicators.avaliacoesEmAndamento +
        indicators.avaliacoesConcluidas;

    final double chartSide =
    maxWidth >= 1280 ? 340 : (maxWidth >= 900 ? 320 : 300);

    if (total == 0) {
      return Container(
        height: chartSide,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey600),
          borderRadius: BorderRadius.circular(AppSizes.s10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 42, color: Colors.grey.shade400),
            appSizedBox(height: AppSpacing.medium),
            appText(
              text: "Você não está vinculado a uma avaliação!",
              color: AppColors.grey700,
              fontSize: AppFontSize.fs16,
            ),
          ],
        ),
      );
    }

    const String naoIniciadas = "Não iniciadas";
    const String emAndamento = "Em andamento";
    const String concluidas = "Concluídas";

    final List<_PieData> pieData = [
      _PieData(
        naoIniciadas,
        indicators.avaliacoesNaoIniciadas.toDouble(),
        Colors.grey.shade300,
      ),
      _PieData(
        emAndamento,
        indicators.avaliacoesEmAndamento.toDouble(),
        Colors.grey.shade600,
      ),
      _PieData(
        concluidas,
        indicators.avaliacoesConcluidas.toDouble(),
        Colors.grey.shade900,
      ),
    ].where((e) => e.value > 0).toList();

    // Destaque por clique
    final bool highlight = _selectedSection != null;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.big),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey600),
        borderRadius: BorderRadius.circular(AppSizes.s10),
      ),
      child: Row(
        children: [
          SizedBox(
            height: chartSide,
            width: chartSide,
            child: SfCircularChart(
              margin: EdgeInsets.zero,
              legend: Legend(isVisible: false),
              series: <DoughnutSeries<_PieData, String>>[
                DoughnutSeries<_PieData, String>(
                  dataSource: pieData,
                  xValueMapper: (_PieData data, _) => data.label,
                  yValueMapper: (_PieData data, _) => data.value,
                  pointColorMapper: (_PieData data, _) {
                    final selected = _selectedSection != null &&
                        _selectedSection!
                            .toLowerCase()
                            .contains(data.label.toLowerCase());
                    return selected || !highlight
                        ? data.color
                        : data.color.withValues(alpha: 0.25);
                  },
                  innerRadius: '65%',
                  radius: '95%',
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelIntersectAction: LabelIntersectAction.shift,
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPointTap: (pt) {
                    if (pt.pointIndex == null) return;
                    _onSectionSelected(
                      pieData[pt.pointIndex!].label.contains('andamento')
                          ? "Avaliações em Andamento"
                          : pieData[pt.pointIndex!].label.contains('Concluídas')
                          ? "Avaliações Concluídas"
                          : "Avaliações Não Iniciadas",
                    );
                  },
                ),
              ],
              annotations: <CircularChartAnnotation>[
                CircularChartAnnotation(
                  widget: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      appText(text: 'Total', color: AppColors.grey700),
                      appText(
                        text: '$total',
                        fontSize: AppFontSize.fs22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.big),
          // Legenda custom (quebra em múltiplas linhas sem overflow)
          Expanded(
            child: Wrap(
              spacing: 16,          // espaço horizontal entre itens
              runSpacing: 10,       // espaço vertical entre “linhas”
              children: pieData.map((e) {
                final selected = _selectedSection != null &&
                    _selectedSection!.toLowerCase().contains(e.label.toLowerCase());

                final chip = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: selected ? e.color : e.color.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: AppColors.grey600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible( // deixa o texto quebrar se necessário
                      child: appText(
                        text: '${e.label} • ${e.value.toInt()}',
                        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                );

                return InkWell(
                  onTap: () {
                    _onSectionSelected(
                      e.label.contains('andamento')
                          ? "Avaliações em Andamento"
                          : e.label.contains('Concluídas')
                          ? "Avaliações Concluídas"
                          : "Avaliações Não Iniciadas",
                    );
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      // evita chips gigantes; permite embrulhar em 2–3 linhas
                      maxWidth: 280,
                    ),
                    child: chip,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- ATIVIDADE RECENTE --------------------
  Widget _recentActivitySection(List<Log> activities, double maxHeight) {
    final bool empty = activities.isEmpty;
    final limited = activities.take(5).toList();
    final double boxHeight = (maxHeight).clamp(280, 500);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.big),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey600),
        borderRadius: BorderRadius.circular(AppSizes.s10),
      ),
      child: SizedBox(
        height: boxHeight.toDouble(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            appText(
              text: 'Atividade Recente',
              fontSize: AppFontSize.fs20,
              fontWeight: FontWeight.bold,
            ),
            appSizedBox(height: AppSpacing.medium),
            if (empty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_toggle_off_outlined,
                          size: 42, color: Colors.grey.shade400),
                      appSizedBox(height: AppSpacing.medium),
                      appText(
                        text: "Nenhum log de atividade registrado.",
                        color: AppColors.grey700,
                        fontSize: AppFontSize.fs16,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.s8),
                  child: ListView.separated(
                    itemCount: limited.length,
                    itemBuilder: (context, i) {
                      final a = limited[i]; // a é Log
                      return _ActivityRow(
                        userName: a.user.name!,
                        message: a.description,
                        when: _formatIsoDateTime(a.logTimestamp), // ISO -> dd/MM/yyyy HH:mm
                      );
                    },
                    separatorBuilder: (context, i) => const Divider(
                      height: 1,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // -------------------- BODY --------------------
  Widget _body(HomeLoadedState state, BoxConstraints constraints) {
    final double contentMaxWidth = 1280;
    final double width = constraints.maxWidth.clamp(0, contentMaxWidth);
    final bool twoCols = width >= 1024;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.big),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          child: appContainer(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.big),
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: AppColors.grey800),
              borderRadius: BorderRadius.circular(AppSizes.s10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(state.userName),
                _dashboards(state.indicators),
                appSizedBox(height: AppSpacing.big),
                // Grid principal
                twoCols
                    ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 3,
                        child:
                        _buildStatusChart(state.indicators, width)),
                    const SizedBox(width: AppSpacing.big),
                    Expanded(
                        flex: 2,
                        child: _recentActivitySection(
                            state.activityLogs, 360)),
                  ],
                )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusChart(state.indicators, width),
                    appSizedBox(height: AppSpacing.big),
                    _recentActivitySection(state.activityLogs, 360),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------- BLOC --------------------
  Widget _blocConsumer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return BlocConsumer<HomeBloc, HomeState>(
          bloc: _bloc,
          listener: (context, state) {},
          builder: (context, state) {
            switch (state) {
              case HomeLoadingState():
                return const AppLoading(color: AppColors.black);
              case HomeLoadedState():
                return _body(state, constraints);
              case HomeErrorState():
                return AppError();
              default:
                return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.white, body: _blocConsumer());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }
}

// -------------------- MODELO INTERNO PARA O PIE --------------------
class _PieData {
  final String label;
  final double value;
  final Color color;
  _PieData(this.label, this.value, this.color);
}

// --- helper: formata ISO -> "dd/MM/yyyy HH:mm" (local time)
String _formatIsoDateTime(String? iso) {
  if (iso == null || iso.trim().isEmpty) return '-';
  try {
    final dt = DateTime.parse(iso).toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  } catch (_) {
    return iso; // fallback: mostra como vier
  }
}

// --- tile de atividade minimalista (estilo do app)
class _ActivityRow extends StatelessWidget {
  final String userName;
  final String message;
  final String when;

  const _ActivityRow({
    required this.userName,
    required this.message,
    required this.when,
  });

  String _initials(String name) {
    final p = name.trim().split(RegExp(r'\s+'));
    if (p.isEmpty) return 'U';
    String r = p.first.isNotEmpty ? p.first[0] : '';
    if (p.length > 1 && p.last.isNotEmpty) r += p.last[0];
    return r.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.black,
            child: Text(
              _initials(userName),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // linha 1: usuário em negrito + mensagem
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: AppColors.black),
                    children: [
                      TextSpan(
                        text: '$userName ',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: message),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  when,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}