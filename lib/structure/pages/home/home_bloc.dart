import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/structure/http/models/DashboardIndicators.dart';
import 'package:flutter_pandyzer/structure/http/models/Log.dart';
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
        final String? userId = prefs.getString('userId');
        if (userId == null) throw Exception("Usuário não logado");

        final int parsedUserId = int.parse(userId);

        final results = await Future.wait([
          UsuarioService.getUsuarioById(parsedUserId),
          HomeRepository.getIndicatorsByUserId(),
          HomeRepository.getActivityLogs(parsedUserId),
        ]);

        // Extrai os resultados
        final User usuario = results[0] as User;
        final DashboardIndicators indicators = results[1] as DashboardIndicators;
        final List<Log> logs = results[2] as List<Log>; // DADOS VINDOS DA API

        emit(HomeLoadedState(
          userName: usuario.name!,
          indicators: indicators,
          activityLogs: logs,
        ));
      } catch (e) {
        debugPrint(e.toString());
        emit(HomeErrorState());
      }
    });
  }
}