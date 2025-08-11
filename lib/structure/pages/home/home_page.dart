import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/core/app_colors.dart';
import 'package:flutter_pandyzer/core/app_font_size.dart';
import 'package:flutter_pandyzer/core/app_sizes.dart';
import 'package:flutter_pandyzer/core/app_spacing.dart';
import 'package:flutter_pandyzer/structure/http/models/ActivityLog.dart';
import 'package:flutter_pandyzer/structure/http/models/DashboardIndicators.dart';
import 'package:flutter_pandyzer/structure/pages/home/home_bloc.dart';
import 'package:flutter_pandyzer/structure/pages/home/home_event.dart';
import 'package:flutter_pandyzer/structure/pages/home/home_state.dart';
import 'package:flutter_pandyzer/structure/widgets/activity_log_tile.dart';
import 'package:flutter_pandyzer/structure/widgets/app_container.dart';
import 'package:flutter_pandyzer/structure/widgets/app_error.dart';
import 'package:flutter_pandyzer/structure/widgets/app_loading.dart';
import 'package:flutter_pandyzer/structure/widgets/app_sized_box.dart';
import 'package:flutter_pandyzer/structure/widgets/dashboard_card.dart';

import '../../widgets/app_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeBloc _bloc = HomeBloc();

  @override
  void initState() {
    super.initState();
    _loadDashboards();
  }

  void _onChangeState(HomeState state){
  }

  void _loadDashboards(){
    _bloc.add(LoadDataHomeEvent());
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
    return Wrap(
      spacing: AppSpacing.big,
      runSpacing: AppSpacing.big,
      children: [
        DashboardCard(
          title: "Avaliações Criadas (Último Mês)",
          value: indicators.avaliacoesCriadas.toString(),
          icon: Icons.note_add_outlined,
          iconColor: Colors.blue.shade700,
        ),
        DashboardCard(
          title: "Avaliações Concluídas (Último Mês)",
          value: indicators.avaliacoesFeitas.toString(),
          icon: Icons.check_circle_outline,
          iconColor: Colors.green.shade700,
        ),
        DashboardCard(
          title: "Avaliações em Andamento",
          value: indicators.avaliacoesEmAndamento.toString(),
          icon: Icons.hourglass_bottom_outlined,
          iconColor: Colors.orange.shade700,
        ),
      ],
    );
  }

  Widget _recentActivitySection(List<ActivityLog> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        appText(
          text: 'Atividade Recente',
          fontSize: AppFontSize.fs22,
          fontWeight: FontWeight.bold,
        ),
        appSizedBox(height: AppSpacing.medium),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey600),
            borderRadius: BorderRadius.circular(AppSizes.s10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.s10),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return ActivityLogTile(activity: activity);
              },
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _body(HomeLoadedState state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.big),
        child: appContainer(
          width: 1600,
          padding: const EdgeInsets.all(AppSpacing.big),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: AppColors.grey800),
            borderRadius: BorderRadius.circular(AppSizes.s10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(state.userName),
              appSizedBox(height: 24),
              _dashboards(state.indicators),
              appSizedBox(height: 32),
              _recentActivitySection(state.activityLogs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blocConsumer() {
    return BlocConsumer<HomeBloc, HomeState>(
      bloc: _bloc,
      listener: (context, state) => _onChangeState(state),
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
    return Scaffold(
      backgroundColor: AppColors.white,
      body: _blocConsumer(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
