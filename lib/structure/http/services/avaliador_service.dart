import 'dart:convert';

import 'package:flutter_pandyzer/core/http_client.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluator.dart';

mixin AvaliadorService {

  static String rota = '/evaluators';

  static Future<List<Evaluator>> getAvaliadores() async {
    try {
      final response = await HttpClient.get(rota);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Evaluator.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao buscar avaliadores: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar avaliadores');
    }
  }

  static Future<Evaluator> getAvaliadorById(int id) async {
    try {
      final response = await HttpClient.get('$rota/$id');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Evaluator.fromJson(data);
      } else {
        throw Exception('Erro ao buscar avaliador: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar avaliador');
    }
  }

  static Future<List<Evaluator>> getEvaluatorsByIdEvaluation (int idEvaluation) async {
    try {

      final response = await HttpClient.get('$rota/evaluation/$idEvaluation');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Evaluator.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao buscar avaliadores: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar avaliadores');
    }
  }

  static Future<void> postAvaliador(Evaluator avaliador) async {
    try {
      final response = await HttpClient.post(rota, body: avaliador.toJson());

      if (response.statusCode != 201) {
        throw Exception('Erro ao criar avaliador: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao criar avaliador');
    }
  }

  static Future<void> putAvaliador(Evaluator avaliador) async {
    if (avaliador.id == null) {
      throw Exception('ID do avaliador é obrigatório para atualização.');
    }

    try {
      final response = await HttpClient.put('$rota/${avaliador.id}', body: avaliador.toJson());

      if (response.statusCode != 200) {
        throw Exception('Erro ao atualizar avaliador: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar avaliador');
    }
  }

  static Future<void> updateEvaluatorStatus(int evaluatorId, int statusId, int evaluationId) async{
    if (evaluatorId == 0) {
      throw Exception('ID do avaliador é obrigatório para atualização do status.');
    }

    try {
      final response = await HttpClient.put('$rota/$evaluatorId/$evaluationId/status/$statusId');

      if (response.statusCode != 200) {
        throw Exception('Erro ao atualizar status do avaliador: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar avaliador');
    }
  }

  static Future<void> deleteAvaliador(int id) async {
    try {
      final response = await HttpClient.delete('$rota/$id');

      if (response.statusCode != 204) {
        throw Exception('Erro ao deletar avaliador: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao deletar avaliador');
    }
  }
}
