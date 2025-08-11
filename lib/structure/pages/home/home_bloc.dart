import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/structure/http/models/ActivityLog.dart';
import 'package:flutter_pandyzer/structure/http/models/DashboardIndicators.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';
import 'package:flutter_pandyzer/structure/http/services/usuario_service.dart';
import 'package:flutter_pandyzer/structure/pages/home/home_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitialState()) {
    on<LoadDataHomeEvent>((event, emit) async {
      emit(HomeLoadingState());
      try {
        final prefs = await SharedPreferences.getInstance();
        String? userId = prefs.getString('userId');

        final results = await Future.wait([
          UsuarioService.getUsuarioById(int.parse(userId!)),
          HomeRepository.getIndicatorsByUserId(),
        ]);

        User usuario = results[0] as User;
        DashboardIndicators indicators = results[1] as DashboardIndicators;

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
          userName: usuario.name!,
          indicators: indicators,
          activityLogs: logs,
        ));
      } catch (e){
        debugPrint(e.toString());
        emit(HomeErrorState());
      }
    });
  }
}