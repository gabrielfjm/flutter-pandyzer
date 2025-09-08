// lib/structure/http/services/avaliador_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_pandyzer/structure/http/models/Evaluator.dart';
import 'package:flutter_pandyzer/structure/http/models/Problem.dart';

class AvaliadorService {
  // Controllers do back:
  // - EvaluatorController  => /evaluators
  // - ProblemController    => /problems
  static const String baseUrl = "http://localhost:8080/evaluators";
  static const String problemsBaseUrl = "http://localhost:8080/problems";

  /// Lista os avaliadores de uma avaliação
  static Future<List<Evaluator>> getByEvaluation(int evaluationId) async {
    final resp = await http.get(Uri.parse("$baseUrl/evaluation/$evaluationId"));
    if (resp.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(resp.body);
      return jsonList.map((e) => Evaluator.fromJson(e)).toList();
    }
    throw Exception(
      "Erro ao buscar avaliadores da avaliação $evaluationId "
          "(${resp.statusCode}) ${resp.body}",
    );
  }

  /// Cria um avaliador
  static Future<Evaluator> create(Evaluator evaluator) async {
    final resp = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(evaluator.toJson()),
    );
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return Evaluator.fromJson(jsonDecode(resp.body));
    }
    throw Exception("Erro ao criar avaliador (${resp.statusCode}) ${resp.body}");
  }

  /// Deleta um avaliador pelo ID (id do registro de Evaluator)
  static Future<void> delete(int evaluatorId) async {
    final resp = await http.delete(Uri.parse("$baseUrl/$evaluatorId"));
    if (resp.statusCode != 204 && resp.statusCode != 200) {
      throw Exception(
        "Erro ao excluir avaliador $evaluatorId "
            "(${resp.statusCode}) ${resp.body}",
      );
    }
  }

  /// Atualiza o status do avaliador (idUser, idEvaluation, idStatus)
  /// Backend: PUT /evaluators/{idUser}/{idEvaluation}/status/{idStatus}
  /// IMPORTANTE: [evaluatorId] aqui é o **id do USUÁRIO** (idUser no back)
  static Future<Evaluator> updateStatus({
    required int evaluatorId,   // idUser
    required int evaluationId,
    required int statusId,
  }) async {
    final resp = await http.put(
      Uri.parse("$baseUrl/$evaluatorId/$evaluationId/status/$statusId"),
      headers: {"Content-Type": "application/json"},
    );
    if (resp.statusCode == 200) {
      return Evaluator.fromJson(jsonDecode(resp.body));
    }
    throw Exception(
      "Erro ao atualizar status (user=$evaluatorId, eval=$evaluationId, status=$statusId) "
          "(${resp.statusCode}) ${resp.body}",
    );
  }

  /// Inicia a avaliação
  /// (seu fluxo pode mapear 'Em andamento' / 'Concluído' por ID; ajuste o statusId aqui se precisar)
  static Future<Evaluator> startEvaluation({
    required int evaluatorId,   // idUser
    required int evaluationId,
  }) {
    return updateStatus(
      evaluatorId: evaluatorId,
      evaluationId: evaluationId,
      statusId: 1, // ajuste se o "iniciar" não for 1 no seu back
    );
  }

  // ==================== PROBLEMAS (usa ProblemController) ====================

  /// Lista problemas por objetivo e usuário avaliador
  /// Backend: GET /problems/objectives/{objectiveId}/users/{userId}
  static Future<List<Problem>> getProblemsByObjectiveAndEvaluator({
    required int objectiveId,
    required int evaluatorUserId,
  }) async {
    final resp = await http.get(
      Uri.parse("$problemsBaseUrl/objectives/$objectiveId/users/$evaluatorUserId"),
    );
    if (resp.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(resp.body);
      return jsonList.map((e) => Problem.fromJson(e)).toList();
    }
    throw Exception(
      "Erro ao buscar problemas (objective=$objectiveId / user=$evaluatorUserId) "
          "(${resp.statusCode}) ${resp.body}",
    );
  }

  /// Alias para compatibilidade
  static Future<List<Problem>> getProblems({
    required int objectiveId,
    required int evaluatorUserId,
  }) {
    return getProblemsByObjectiveAndEvaluator(
      objectiveId: objectiveId,
      evaluatorUserId: evaluatorUserId,
    );
  }

  /// Fallback para remoção (sem endpoint dedicado no back)
  static Future<void> deleteFromEvaluation({
    required int evaluatorId,
    required int evaluationId,
  }) async {
    await delete(evaluatorId);
  }

  // ===== ALIAS para compatibilidade com chamadas antigas =====
  static Future<Evaluator> updateEvaluatorStatus({
    required int evaluatorId,
    required int evaluationId,
    required int statusId,
  }) {
    return updateStatus(
      evaluatorId: evaluatorId,
      evaluationId: evaluationId,
      statusId: statusId,
    );
  }
}
