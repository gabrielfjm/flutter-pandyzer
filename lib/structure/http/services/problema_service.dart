import 'dart:convert';
import 'package:flutter_pandyzer/core/http_client.dart';
import 'package:flutter_pandyzer/structure/http/models/Problem.dart';

mixin ProblemaService {
  static const String rota = '/problems';

  // ===== Nomes padronizados =====
  static Future<List<Problem>> getAll() async {
    final response = await HttpClient.get(rota);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Problem.fromJson(e)).toList();
    }
    throw Exception('Erro ao buscar problemas: ${response.statusCode}');
  }

  static Future<Problem> getById(int id) async {
    final response = await HttpClient.get('$rota/$id');
    if (response.statusCode == 200) {
      return Problem.fromJson(jsonDecode(response.body));
    }
    throw Exception('Erro ao buscar problema $id: ${response.statusCode}');
  }

  /// GET /problems/objectives/{objectiveId}
  static Future<List<Problem>> getByObjective(int objectiveId) async {
    final response = await HttpClient.get('$rota/objectives/$objectiveId');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Problem.fromJson(e)).toList();
    }
    throw Exception(
        'Erro ao buscar problemas do objetivo $objectiveId: ${response.statusCode}');
  }

  /// GET /problems/objectives/{objectiveId}/users/{userId}
  static Future<List<Problem>> getByObjectiveAndUser({
    required int objectiveId,
    required int userId,
  }) async {
    final response =
    await HttpClient.get('$rota/objectives/$objectiveId/users/$userId');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Problem.fromJson(e)).toList();
    }
    throw Exception(
        'Erro ao buscar problemas (objective=$objectiveId, user=$userId): ${response.statusCode}');
  }

  static Future<void> create(Problem problem) async {
    final response = await HttpClient.post(rota, body: problem.toJson());
    if (response.statusCode != 201) {
      throw Exception('Erro ao criar problema: ${response.statusCode}');
    }
  }

  static Future<void> update(Problem problem) async {
    if (problem.id == null) {
      throw Exception('ID do problema é obrigatório para atualização.');
    }
    final response =
    await HttpClient.put('$rota/${problem.id}', body: problem.toJson());
    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar problema: ${response.statusCode}');
    }
  }

  static Future<void> delete(int id) async {
    final response = await HttpClient.delete('$rota/$id');
    if (response.statusCode != 204) {
      throw Exception('Erro ao deletar problema: ${response.statusCode}');
    }
  }

  // ===== Aliases (compat com código antigo) =====
  static Future<List<Problem>> getProblemas() => getAll();
  static Future<Problem> getProblemaById(int id) => getById(id);

  static Future<List<Problem>> getProblemsByIdObjetivoAndIdEvaluator(
      int idObjetivo, int idEvaluator) =>
      getByObjectiveAndUser(objectiveId: idObjetivo, userId: idEvaluator);

  static Future<void> postProblema(Problem problema) => create(problema);
  static Future<void> putProblema(Problem problema) => update(problema);
  static Future<void> deleteProblema(int id) => delete(id);
}
