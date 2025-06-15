import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/Heuristic.dart';
import 'package:flutter_pandyzer/structure/http/models/Problem.dart';
import 'package:flutter_pandyzer/structure/http/models/Severity.dart';
import 'package:flutter_pandyzer/structure/pages/problema/problema_event.dart';
import 'package:flutter_pandyzer/structure/pages/problema/problema_repository.dart';
import 'package:flutter_pandyzer/structure/pages/problema/problema_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProblemaBloc extends Bloc<ProblemaEvent, ProblemaState> {
  ProblemaBloc() : super(ProblemaInitial()) {
    on<LoadProblemaPageData>((event, emit) async {
      emit(ProblemaLoading(oldState: state));
      try {
        final objectives = await ProblemaRepository.getObjectivesByEvaluationId(event.evaluationId);
        List<Problem> allProblemsForEvaluator = [];

        await Future.forEach(objectives, (objective) async {
          if (objective.id != null) {
            final problems = await ProblemaRepository.getProblemsByIdObjetivoAndIdEvaluator(
              objective.id!,
              event.evaluatorId,
            );
            allProblemsForEvaluator.addAll(problems);
          }
        });

        final evaluators = await ProblemaRepository.getEvaluatorsByIdEvaluation(event.evaluationId);
        final currentUserEvaluator = evaluators.firstWhereOrNull(
              (evaluator) => evaluator.user?.id == event.evaluatorId,
        );

        final results = await Future.wait([
          ProblemaRepository.getAvaliacoesById(event.evaluationId),
          ProblemaRepository.getHeuristics(),
          ProblemaRepository.getSeverities(),
        ]);

        emit(ProblemaLoaded(
          evaluation: results[0] as Evaluation,
          objectives: objectives,
          heuristics: results[1] as List<Heuristic>,
          severities: results[2] as List<Severity>,
          initialProblems: allProblemsForEvaluator,
          currentUserStatusId: currentUserEvaluator?.status?.id,
        ));
      } catch (e) {
        emit(ProblemaError(e.toString()));
      }
    });

    on<UpdateProblems>((event, emit) async {
      emit(ProblemaLoading(oldState: state));
      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userId');
        if (userId == null) {
          emit(const ProblemaError("Usuário não autenticado."));
          return;
        }

        final currentUser = await ProblemaRepository.getUsuarioById(int.parse(userId));
        final now = DateTime.now().toIso8601String();

        final List<Future> operations = [];

        for (final problemId in event.problemIdsToDelete) {
          operations.add(ProblemaRepository.deleteProblem(problemId));
        }

        for (final problem in event.problemsToUpsert) {
          problem.user = currentUser;
          problem.register = now;

          if (problem.id == null) {
            operations.add(ProblemaRepository.createProblema(problem));
          } else {
            operations.add(ProblemaRepository.updateProblem(problem));
          }
        }
        await Future.wait(operations);

        // --- LÓGICA MODIFICADA ---
        // 1. Emite o estado de sucesso para o listener da UI mostrar o Toast.
        emit(ProblemaSaveSuccess(
          evaluation: state.evaluation,
          objectives: state.objectives,
          heuristics: state.heuristics,
          severities: state.severities,
          initialProblems: state.initialProblems,
          currentUserStatusId: state.currentUserStatusId,
        ));

        // 2. Dispara o evento para recarregar os dados da página atual.
        add(LoadProblemaPageData(
          evaluationId: event.evaluationId,
          evaluatorId: event.evaluatorId,
        ));

      } catch (e) {
        emit(ProblemaError(e.toString()));
      }
    });


    on<FinalizeEvaluation>((event, emit) async {
      emit(ProblemaLoading(oldState: state));
      try {
        await ProblemaRepository.updateEvaluatorStatus(
          event.evaluatorId,
          event.statusId,
          event.evaluationId,
        );
        emit(const ProblemaFinalizeSuccess());
      } catch (e) {
        emit(ProblemaError(e.toString()));
      }
    });
  }
}