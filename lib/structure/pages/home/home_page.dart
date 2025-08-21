import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/structure/http/models/ActivityLog.dart';
import 'package:flutter_pandyzer/structure/http/models/ChartData.dart';
import 'package:flutter_pandyzer/structure/http/models/DashboardIndicators.dart';
import 'package:flutter_pandyzer/structure/http/models/Log.dart';
import 'package:flutter_pandyzer/structure/pages/home/home_bloc.dart';
import 'package:flutter_pandyzer/structure/pages/home/home_event.dart';
import 'package:flutter_pandyzer/structure/pages/home/home_state.dart';
import 'package:flutter_pandyzer/structure/widgets/activity_log_tile.dart';
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
    _loadDashboards();
  }

  void _loadDashboards() {
    _bloc.add(LoadDataHomeEvent());
  }

  void _onSectionSelected(String section) {
    setState(() {
      if (_selectedSection == section) {
        _selectedSection = null;
      } else {
        _selectedSection = section;
      }
    });
  }

  Widget _header(String userName) {
    return appContainer(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.centerLeft,
      child: appText(
        text: 'Seja bem-vindo, $userName!',
        fontSize: AppFontSize.fs32,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
    );
  }

  Widget _dashboards(DashboardIndicators indicators) {
    const String naoIniciadas = "Avaliações Não Iniciadas";
    const String emAndamento = "Avaliações em Andamento";
    const String concluidas = "Avaliações Concluídas";

    return Wrap(
      spacing: AppSpacing.big,
      runSpacing: AppSpacing.big,
      children: [
        GestureDetector(
          onTap: () => _onSectionSelected(naoIniciadas),
          child: DashboardCard(
            title: naoIniciadas,
            value: indicators.avaliacoesNaoIniciadas.toString(),
            icon: Icons.play_circle_outline,
            iconColor: Colors.grey.shade400,
            isHighlighted: _selectedSection == naoIniciadas,
          ),
        ),
        GestureDetector(
          onTap: () => _onSectionSelected(emAndamento),
          child: DashboardCard(
            title: emAndamento,
            value: indicators.avaliacoesEmAndamento.toString(),
            icon: Icons.hourglass_bottom_outlined,
            iconColor: Colors.grey.shade600,
            isHighlighted: _selectedSection == emAndamento,
          ),
        ),
        GestureDetector(
          onTap: () => _onSectionSelected(concluidas),
          child: DashboardCard(
            title: concluidas,
            value: indicators.avaliacoesConcluidas.toString(),
            icon: Icons.check_circle_outline,
            iconColor: Colors.grey.shade800,
            isHighlighted: _selectedSection == concluidas,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBarChart(DashboardIndicators indicators) {
    final totalAvaliacoes = indicators.avaliacoesNaoIniciadas +
        indicators.avaliacoesEmAndamento +
        indicators.avaliacoesConcluidas;

    if (totalAvaliacoes == 0) {
      return Container(
        height: 350,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
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

    const String naoIniciadas = "Avaliações Não Iniciadas";
    const String emAndamento = "Avaliações em Andamento";
    const String concluidas = "Avaliações Concluídas";

    final List<ChartData> chartData = [
      if (indicators.avaliacoesNaoIniciadas > 0)
        ChartData(naoIniciadas, indicators.avaliacoesNaoIniciadas.toDouble(), Colors.grey.shade400),
      if (indicators.avaliacoesEmAndamento > 0)
        ChartData(emAndamento, indicators.avaliacoesEmAndamento.toDouble(), Colors.grey.shade600),
      if (indicators.avaliacoesConcluidas > 0)
        ChartData(concluidas, indicators.avaliacoesConcluidas.toDouble(), Colors.grey.shade800),
    ];

    if (chartData.isEmpty) {
      return const SizedBox(height: 350);
    }

    final double maxValue = chartData.map((d) => d.y).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 350,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        primaryXAxis: CategoryAxis(
          majorGridLines: const MajorGridLines(width: 0),
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          labelIntersectAction: AxisLabelIntersectAction.wrap,
          labelStyle: const TextStyle(
            color: AppColors.black,
            fontSize: AppFontSize.fs12,
            fontWeight: FontWeight.bold,
          ),
        ),
        primaryYAxis: NumericAxis(
          interval: 1,
          maximum: (maxValue + 1.5),
          majorGridLines: const MajorGridLines(
            width: 1,
            dashArray: <double>[4, 3],
          ),
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          labelStyle: const TextStyle(fontSize: 0),
        ),
        tooltipBehavior: TooltipBehavior(enable: true, header: '', canShowMarker: false, format: 'point.x : point.y'),
        series: <CartesianSeries<ChartData, String>>[
          ColumnSeries<ChartData, String>(
            dataSource: chartData,
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => data.y,
            pointColorMapper: (ChartData data, _) =>
            _selectedSection == null || _selectedSection == data.x
                ? data.color
                : data.color.withValues(alpha: 0.3),
            width: 0.6,
            borderRadius: const BorderRadius.all(Radius.circular(AppSizes.s10)),
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                return Container(
                  transform: Matrix4.translationValues(0, -15, 0),
                  child: appText(
                    text: (data as ChartData).y.toInt().toString(),
                    color: AppColors.black,
                    fontSize: AppFontSize.fs16,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            onPointTap: (ChartPointDetails details) {
              if (details.pointIndex != null) {
                _onSectionSelected(chartData[details.pointIndex!].x);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _recentActivitySection(List<Log> activities) {
    // Verifica se a lista de atividades está vazia no início do método.
    if (activities.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          appText(text: 'Atividade Recente', fontSize: AppFontSize.fs22, fontWeight: FontWeight.bold),
          appSizedBox(height: AppSpacing.medium),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey600),
                borderRadius: BorderRadius.circular(AppSizes.s10),
              ),
              // Mostra o conteúdo do estado vazio centralizado
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_toggle_off_outlined, size: 48, color: Colors.grey.shade400),
                    appSizedBox(height: AppSpacing.medium),
                    appText(
                      text: "Nenhum log de atividade registrado.",
                      color: AppColors.grey700,
                      fontSize: AppFontSize.fs16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // O resto do código continua como estava se a lista não estiver vazia.
    final limitedActivities = activities.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        appText(text: 'Atividade Recente', fontSize: AppFontSize.fs22, fontWeight: FontWeight.bold),
        appSizedBox(height: AppSpacing.medium),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey600),
              borderRadius: BorderRadius.circular(AppSizes.s10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.s10),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: limitedActivities.length,
                itemBuilder: (context, index) => ActivityLogTile(activity: limitedActivities[index]),
                separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _body(HomeLoadedState state) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.big),
      child: appContainer(
        width: 1600,
        padding: const EdgeInsets.all(AppSpacing.big),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: AppColors.grey800),
          borderRadius: BorderRadius.circular(AppSizes.s10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(state.userName),
                  appSizedBox(height: 24),
                  _dashboards(state.indicators),
                  const Spacer(),
                  _buildStatusBarChart(state.indicators),
                ],
              ),
            ),
            VerticalDivider(
              width: AppSpacing.big * 2,
              thickness: 1,
              color: AppColors.grey400,
              indent: 20,
              endIndent: 20,
            ),
            Expanded(
              flex: 2,
              child: _recentActivitySection(state.activityLogs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blocConsumer() {
    return BlocConsumer<HomeBloc, HomeState>(
      bloc: _bloc,
      listener: (context, state) {},
      builder: (context, state) {
        switch (state) {
          case HomeLoadingState():
            return const AppLoading(color: AppColors.black);
          case HomeLoadedState():
            return Center(child: _body(state));
          case HomeErrorState():
            return AppError();
          default:
            return const SizedBox.shrink();
        }
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
