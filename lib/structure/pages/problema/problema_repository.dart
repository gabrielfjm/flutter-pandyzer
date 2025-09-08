// Camada fina de repositório: chama seus services padronizados.

import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluator.dart';
import 'package:flutter_pandyzer/structure/http/models/Heuristic.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/http/models/Problem.dart';
import 'package:flutter_pandyzer/structure/http/models/Severity.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';

// Services existentes no projeto
import 'package:flutter_pandyzer/structure/http/services/avaliacao_service.dart';
import 'package:flutter_pandyzer/structure/http/services/avaliador_service.dart';
import 'package:flutter_pandyzer/structure/http/services/heuristica_service.dart';
import 'package:flutter_pandyzer/structure/http/services/objetivo_service.dart';
import 'package:flutter_pandyzer/structure/http/services/problema_service.dart';
import 'package:flutter_pandyzer/structure/http/services/severidade_service.dart';

mixin ProblemaRepository {
  // ===== Evaluation / Objectives =====
  static Future<Evaluation> getEvaluationById(int id) =>
      AvaliacaoService.getById(id);

  static Future<List<Objective>> getObjectives(int evaluationId) =>
      ObjetivoService.getObjetivoByIdAvaliacao(evaluationId);

  // ===== Heuristics / Severities =====
  static Future<List<Heuristic>> getHeuristics() =>
      HeuristicaService.getHeuristicas();

  static Future<List<Severity>> getSeverities() =>
      SeveridadeService.getSeveridades();

  // ===== Evaluators (para descobrir status do usuário avaliador) =====
  static Future<List<Evaluator>> getEvaluatorsByEvaluation(int evaluationId) =>
      AvaliadorService.getByEvaluation(evaluationId);

  // ===== Problems =====
  static Future<List<Problem>> getProblemsByObjectiveAndUser({
    required int objectiveId,
    required int userId,
  }) =>
      ProblemaService.getByObjectiveAndUser(
        objectiveId: objectiveId,
        userId: userId,
      );

  static Future<void> upsertProblem(Problem p) async {
    if (p.id == null) {
      await ProblemaService.postProblema(p);
    } else {
      await ProblemaService.putProblema(p);
    }
  }

  static Future<void> deleteProblem(int id) =>
      ProblemaService.deleteProblema(id);

  // ===== Finalização (muda status do avaliador) =====
  static Future<void> finalizeEvaluation({
    required int evaluatorUserId,
    required int evaluationId,
    required int statusId, // ex.: 2 = Concluída
  }) =>
      AvaliadorService.updateEvaluatorStatus(
        evaluatorId: evaluatorUserId,
        evaluationId: evaluationId,
        statusId: statusId,
      );
}
