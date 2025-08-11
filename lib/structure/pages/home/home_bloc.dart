import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/structure/http/models/ActivityLog.dart';
import 'package:flutter_pandyzer/structure/http/models/DashboardIndicators.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitialState()) {
    on<LoadDataHomeEvent>((event, emit) async {
      emit(HomeLoadingState());
      try {
        await Future.delayed(const Duration(seconds: 1));

        DashboardIndicators indicators = DashboardIndicators(
          avaliacoesCriadas: 12,
          avaliacoesFeitas: 8,
          avaliacoesEmAndamento: 4,
        );

        List<ActivityLog> logs = [
          ActivityLog(
            userName: 'Ana Paula',
            action: 'adicionou um novo problema na avaliação',
            evaluationTitle: 'E-commerce de Roupas',
            timestamp: 'Hoje às 14:10',
          ),
          ActivityLog(
            userName: 'Carlos Silva',
            action: 'concluiu a avaliação',
            evaluationTitle: 'App de Streaming de Música',
            timestamp: 'Hoje às 11:35',
          ),
          ActivityLog(
            userName: 'Bibo',
            action: 'editou a descrição da avaliação',
            evaluationTitle: 'Sistema de Gestão Interna',
            timestamp: 'Ontem às 17:50',
          ),
          ActivityLog(
            userName: 'Juliana Costa',
            action: 'se cadastrou como avaliadora na',
            evaluationTitle: 'Plataforma de Cursos Online',
            timestamp: 'Há 2 dias',
          ),
          ActivityLog(
            userName: 'Rafael Martins',
            action: 'adicionou um novo problema na avaliação',
            evaluationTitle: 'App de Streaming de Música',
            timestamp: 'Há 3 dias',
          ),
        ];

        emit(HomeLoadedState(
          userName: 'Bibo', // Nome do usuário logado
          indicators: indicators,
          activityLogs: logs, // Passa a lista de logs para o estado
        ));
      } catch (e){
        debugPrint(e.toString());
        emit(HomeErrorState());
      }
    });
  }
}