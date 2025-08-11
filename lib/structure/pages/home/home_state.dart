import 'package:flutter_pandyzer/structure/http/models/ActivityLog.dart';
import 'package:flutter_pandyzer/structure/http/models/DashboardIndicators.dart';

abstract class HomeState{
  final String userName;
  final DashboardIndicators indicators;
  final List<ActivityLog> activityLogs;

  HomeState({
    required this.indicators,
    required this.userName,
    required this.activityLogs,
  });
}

class HomeInitialState extends HomeState{
  HomeInitialState(): super(
    indicators: DashboardIndicators(avaliacoesCriadas: 0, avaliacoesFeitas: 0, avaliacoesEmAndamento: 0),
    userName: '',
    activityLogs: [],
  );
}

class HomeLoadingState extends HomeState{
  HomeLoadingState(): super(
    indicators: DashboardIndicators(avaliacoesCriadas: 0, avaliacoesFeitas: 0, avaliacoesEmAndamento: 0),
    userName: '',
    activityLogs: [],
  );
}

class HomeLoadedState extends HomeState {
  HomeLoadedState({
    required super.indicators,
    required super.userName,
    required super.activityLogs,
  });
}

class HomeErrorState extends HomeState{
  HomeErrorState(): super(
    indicators: DashboardIndicators(avaliacoesCriadas: 0, avaliacoesFeitas: 0, avaliacoesEmAndamento: 0),
    userName: '',
    activityLogs: [],
  );
}