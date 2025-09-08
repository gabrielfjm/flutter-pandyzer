import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluator.dart';
import 'package:flutter_pandyzer/structure/http/models/Problem.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';

import 'problema_event.dart';
import 'problema_state.dart';
import 'problema_repository.dart';

class ProblemaBloc extends Bloc<ProblemaEvent, ProblemaState> {
  ProblemaBloc() : super(const ProblemaInitial()) {
    // ====== LOAD ======
    on<LoadProblemaPageData>((event, emit) async {
      emit(ProblemaLoading.fromOld(state));
      try {
        final evaluation =
        await ProblemaRepository.getEvaluationById(event.evaluationId);

        final objectives =
        await ProblemaRepository.getObjectives(event.evaluationId);

        final heuristics = await ProblemaRepository.getHeuristics();
        final severities = await ProblemaRepository.getSeverities();

        // Descobre o status atual do USUÁRIO avaliador (na lista de evaluators da avaliação)
        final evaluators =
        await ProblemaRepository.getEvaluatorsByEvaluation(event.evaluationId);

        int? currentStatusId;
        try {
          final Evaluator me = evaluators
              .firstWhere((e) => e.user?.id == event.evaluatorUserId);
          currentStatusId = me.status?.id;
        } catch (_) {
          currentStatusId = null;
        }

        // Carrega os problemas do USUÁRIO avaliador para cada objetivo
        final List<Problem> initialProblems = [];
        for (final obj in objectives) {
          if (obj.id == null) continue;
          final probs = await ProblemaRepository.getProblemsByObjectiveAndUser(
            objectiveId: obj.id!,
            userId: event.evaluatorUserId,
          );
          initialProblems.addAll(probs);
        }

        emit(ProblemaLoaded(
          evaluation_: evaluation,
          objectives_: objectives,
          heuristics_: heuristics,
          severities_: severities,
          initialProblems_: initialProblems,
          currentUserStatusId_: currentStatusId,
        ));
      } catch (e) {
        emit(ProblemaError(
          message: e.toString(),
          evaluation: state.evaluation,
          objectives: state.objectives,
          heuristics: state.heuristics ?? const [],
          severities: state.severities ?? const [],
          initialProblems: state.initialProblems ?? const [],
          currentUserStatusId: state.currentUserStatusId,
        ));
      }
    });

    // ====== UPSERT / DELETE PROBLEMS ======
    on<UpdateProblems>((event, emit) async {
      emit(ProblemaLoading.fromOld(state));

      try {
        // Apaga os removidos
        for (final id in event.problemIdsToDelete) {
          await ProblemaRepository.deleteProblem(id);
        }

        // Insere/atualiza os restantes
        for (final p in event.problemsToUpsert) {
          // GARANTIR usuário do avaliador
          p.user ??= User(id: event.evaluatorUserId);

          // Validações simples
          if (p.objective?.id == null) {
            throw Exception('Problema sem objetivo.');
          }
          if (p.heuristic?.id == null) {
            throw Exception('Selecione uma heurística.');
          }
          if (p.severity?.id == null) {
            throw Exception('Selecione uma severidade.');
          }

          await ProblemaRepository.upsertProblem(p);
        }

        // Recarrega os problemas (para refletir ids recém-criados etc.)
        final refreshed = await _reloadProblemsForUser(
          evaluationId: event.evaluationId,
          evaluatorUserId: event.evaluatorUserId,
        );

        emit(ProblemaSaveSuccess(
          evaluation_: state.evaluation!,
          objectives_: state.objectives,
          heuristics_: state.heuristics ?? const [],
          severities_: state.severities ?? const [],
          initialProblems_: refreshed,
          currentUserStatusId_: state.currentUserStatusId,
        ));
      } catch (e) {
        emit(ProblemaError(
          message: e.toString(),
          evaluation: state.evaluation,
          objectives: state.objectives,
          heuristics: state.heuristics ?? const [],
          severities: state.severities ?? const [],
          initialProblems: state.initialProblems ?? const [],
          currentUserStatusId: state.currentUserStatusId,
        ));
      }
    });

    // ====== FINALIZE ======
    on<FinalizeEvaluation>((event, emit) async {
      emit(ProblemaLoading.fromOld(state));
      try {
        await ProblemaRepository.finalizeEvaluation(
          evaluatorUserId: event.evaluatorUserId,
          evaluationId: event.evaluationId,
          statusId: event.statusId, // ex.: 2 = Concluída
        );

        emit(const ProblemaFinalizeSuccess());
      } catch (e) {
        emit(ProblemaError(
          message: e.toString(),
          evaluation: state.evaluation,
          objectives: state.objectives,
          heuristics: state.heuristics ?? const [],
          severities: state.severities ?? const [],
          initialProblems: state.initialProblems ?? const [],
          currentUserStatusId: state.currentUserStatusId,
        ));
      }
    });
  }

  Future<List<Problem>> _reloadProblemsForUser({
    required int evaluationId,
    required int evaluatorUserId,
  }) async {
    final objectives = await ProblemaRepository.getObjectives(evaluationId);
    final List<Problem> all = [];
    for (final o in objectives) {
      if (o.id != null) {
        final lista = await ProblemaRepository.getProblemsByObjectiveAndUser(
          objectiveId: o.id!,
          userId: evaluatorUserId,
        );
        all.addAll(lista);
      }
    }
    return all;
  }
}
