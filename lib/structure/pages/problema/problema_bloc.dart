import 'package:bloc/bloc.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/Heuristic.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/http/models/Severity.dart';
import 'package:flutter_pandyzer/structure/pages/avaliacoes/avaliacoes_repository.dart';
import 'package:flutter_pandyzer/structure/pages/problema/problema_event.dart';
import 'package:flutter_pandyzer/structure/pages/problema/problema_repository.dart';
import 'package:flutter_pandyzer/structure/pages/problema/problema_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProblemaBloc extends Bloc<ProblemaEvent, ProblemaState> {
  ProblemaBloc() : super(ProblemaInitial()) {
    on<LoadProblemaPageData>((event, emit) async {
      emit(ProblemaLoading());
      try {
        final results = await Future.wait([
          ProblemaRepository.getAvaliacoesById(event.evaluationId),
          ProblemaRepository.getObjectivesByEvaluationId(event.evaluationId),
          ProblemaRepository.getHeuristics(),
          ProblemaRepository.getSeverities(),
        ]);

        emit(ProblemaLoaded(
          evaluation: results[0] as Evaluation,
          objectives: results[1] as List<Objective>,
          heuristics: results[2] as List<Heuristic>,
          severities: results[3] as List<Severity>,
        ));
      } catch (e) {
        emit(ProblemaError(e.toString()));
      }
    });

    on<SaveProblemas>((event, emit) async {
      emit(ProblemaLoading());
      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userId');
        if (userId == null) {
          emit(const ProblemaError("Usuário não autenticado."));
          return;
        }

        final currentUser = await ProblemaRepository.getUsuarioById(int.parse(userId));
        final now = DateTime.now().toIso8601String();

        for (var entry in event.problemsToSave.entries) {
          final objectiveId = entry.key;
          final problems = entry.value;

          for (var problem in problems) {
            problem.objective = Objective(id: objectiveId);
            problem.user = currentUser;
            problem.register = now;
            await ProblemaRepository.createProblema(problem);
          }
        }

        emit(ProblemaSaveSuccess());
      } catch (e) {
        emit(ProblemaError(e.toString()));
      }
    });
  }
}