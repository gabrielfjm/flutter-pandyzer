import 'package:flutter_pandyzer/structure/http/models/ApplicationType.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluator.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/http/models/Problem.dart';
import 'package:flutter_pandyzer/structure/http/models/Status.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';
import 'package:flutter_pandyzer/structure/http/services/application_type_service.dart';

// Services
import 'package:flutter_pandyzer/structure/http/services/avaliacao_service.dart';
import 'package:flutter_pandyzer/structure/http/services/avaliador_service.dart';
import 'package:flutter_pandyzer/structure/http/services/objetivo_service.dart';
import 'package:flutter_pandyzer/structure/http/services/problema_service.dart';
import 'package:flutter_pandyzer/structure/http/services/status_service.dart';
import 'package:flutter_pandyzer/structure/http/services/usuario_service.dart';

mixin AvaliacoesRepository {
  // ========= APLICAÇÃO / DOMÍNIOS =========
  static Future<List<ApplicationType>> getApplicationTypes() {
    return ApplicationTypeService.getAll();
  }

  // alias antigo
  static Future<List<ApplicationType>> getDominios() => getApplicationTypes();

  // ========= USUÁRIO =========
  static Future<User> getUsuarioById(int id) {
    return UsuarioService.getUsuarioById(id);
  }

  // ========= AVALIAÇÕES =========
  static Future<List<Evaluation>> getAvaliacoes() {
    return AvaliacaoService.filter();
  }

  static Future<List<Evaluation>> getByCreator(int userId) {
    return AvaliacaoService.getByCreator(userId);
  }

  static Future<List<Evaluation>> getMinhasAvaliacoes(int userId) =>
      getByCreator(userId);

  static Future<List<Evaluation>> getCommunityEvaluations(int userId) {
    return AvaliacaoService.getCommunityEvaluations(userId);
  }

  static Future<List<Evaluation>> getAvaliacoesComunidade(int userId) =>
      getCommunityEvaluations(userId);

  static Future<Evaluation> getEvaluationById(int id) {
    return AvaliacaoService.getById(id);
  }

  static Future<Evaluation> getAvaliacoesById(int id) =>
      getEvaluationById(id);

  static Future<Evaluation> getAvaliacaoById(int id) =>
      getEvaluationById(id);

  static Future<Evaluation> insertAvaliacao(Evaluation e) {
    return AvaliacaoService.insert(e);
  }

  static Future<Evaluation> createAvaliacao(Evaluation e) =>
      insertAvaliacao(e);

  static Future<Evaluation> updateAvaliacao(Evaluation e) {
    if (e.id == null) {
      throw Exception('ID da avaliação é obrigatório para update.');
    }
    return AvaliacaoService.update(e.id!, e);
  }

  static Future<Evaluation> putAvaliacao(Evaluation e) =>
      updateAvaliacao(e);

  static Future<void> deleteAvaliacao(int id) =>
      AvaliacaoService.delete(id);

  static Future<List<Evaluation>> filter({
    String? description,
    int? statusId,
    int? creatorId,
  }) {
    return AvaliacaoService.filter(
      description: description,
      statusId: statusId,
      creatorId: creatorId,
    );
  }

  // ========= OBJETIVOS =========
  static Future<List<Objective>> getObjectivesByEvaluationId(int evaluationId) {
    return ObjetivoService.getByEvaluationId(evaluationId);
  }

  static Future<Objective> insertObjetivo(Objective o) {
    return ObjetivoService.postObjetivo(o);
  }

  static Future<Objective> createObjetivo(Objective o) =>
      insertObjetivo(o);

  static Future<void> deleteObjetivo(int id) =>
      ObjetivoService.deleteObjetivo(id);

  // ========= AVALIADORES =========
  static Future<List<Evaluator>> getEvaluatorsByIdEvaluation(
      int evaluationId) {
    return AvaliadorService.getByEvaluation(evaluationId);
  }

  // ---------- Avaliadores (somente usuários) ----------
  static Future<List<User>> getUsuariosAvaliadores(int evaluationId) async {
    // Na tela de CADASTRO você chamou com "0" só para preencher o seletor.
    // Não existe um endpoint para "todos os usuários avaliadores", então
    // evitamos 404 e retornamos vazio aqui.
    if (evaluationId <= 0) return <User>[];

    // Para telas de DETALHE, mapeamos os Evaluator -> User
    final evaluators = await getEvaluatorsByIdEvaluation(evaluationId); // List<Evaluator>
    final users = evaluators.map((e) => e.user).whereType<User>().toList();
    return users;
  }


  static Future<Evaluator> insertAvaliador(Evaluator e) {
    return AvaliadorService.create(e);
  }

  static Future<Evaluator> createAvaliador(Evaluator e) =>
      insertAvaliador(e);

  static Future<void> deleteAvaliador(int evaluatorId) =>
      AvaliadorService.delete(evaluatorId);

  static Future<void> deleteEvaluator(int evaluatorId) =>
      deleteAvaliador(evaluatorId);

  static Future<Evaluator> startEvaluation({
    required int evaluatorId,
    required int evaluationId,
    int? evaluatorUserId,
  }) {
    final int userId = evaluatorUserId ?? evaluatorId;
    return AvaliadorService.updateStatus(
      evaluatorId: userId,
      evaluationId: evaluationId,
      statusId: 1,
    );
  }

  static Future<Evaluator> updateEvaluatorStatus(
      int evaluatorUserId,
      int statusId, {
        required int evaluationId,
      }) {
    return AvaliadorService.updateStatus(
      evaluatorId: evaluatorUserId,
      evaluationId: evaluationId,
      statusId: statusId,
    );
  }

  // ========= PROBLEMAS =========
  static Future<List<Problem>> getProblemsByIdObjetivoAndIdEvaluator(
      int objectiveId,
      int evaluatorUserId,
      ) {
    return ProblemaService.getByObjectiveAndUser(
      objectiveId: objectiveId,
      userId: evaluatorUserId,
    );
  }

  static Future<void> deleteProblem(int problemId) =>
      ProblemaService.deleteProblema(problemId);

  // ========= STATUS =========
  static Future<List<Status>> getStatuses() async {
    try {
      return await StatusService.getAll();
    } catch (_) {
      return StatusService.getStatuses();
    }
  }

  static Future<Status> getStatusById(int id) async {
    try {
      return await StatusService.getById(id);
    } catch (_) {
      return StatusService.getStatusById(id);
    }
  }

  static Future<List<User>> getCreatorsForUser(int userId) async {
    // Puxa “Minhas” (criadas por mim) + “Comunidade” (públicas de outros)
    final minhas = await getByCreator(userId);            // /evaluations/creator/{id}
    final comunidade = await getCommunityEvaluations(userId);

    final all = [...minhas, ...comunidade];

    // Extrai os usuários “criadores” (campo Evaluation.user)
    final creators = <User>[];
    for (final e in all) {
      final u = e.user;
      if (u?.id != null) creators.add(u!);
    }

    // Remove duplicados por id
    final map = <int, User>{};
    for (final u in creators) {
      map[u.id!] = u;
    }
    final unique = map.values.toList();

    // Ordena por nome (opcional)
    unique.sort((a, b) => (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()));

    return unique;
  }

  // avaliacoes_repository.dart
  static Future<List<Evaluation>> getByEvaluatorUser(int userId) {
    return AvaliacaoService.getByEvaluator(userId);
  }

}
