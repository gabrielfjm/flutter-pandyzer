import 'dart:convert';

import 'package:flutter_pandyzer/core/http_client.dart';
import 'package:flutter_pandyzer/structure/http/models/Problem.dart';

mixin ProblemaService {

  static String rota = '/problems';

  static Future<List<Problem>> getProblemas() async {
    try {
      final response = await HttpClient.get(rota);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Problem.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao buscar problemas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar problemas');
    }
  }

  static Future<Problem> getProblemaById(int id) async {
    try {
      final response = await HttpClient.get('$rota/$id');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Problem.fromJson(data);
      } else {
        throw Exception('Erro ao buscar problema: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar problema');
    }
  }

  static Future<List<Problem>> getProblemsByIdObjetivoAndIdEvaluator(int idObjetivo, int idEvaluator) async {
    try {
      final response = await HttpClient.get('$rota/objectives/$idObjetivo/users/$idEvaluator');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Problem.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao buscar problema por objetivo e avaliador: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar problema por objetivo e avaliador');
    }
  }

  static Future<void> postProblema(Problem problema) async {
    try {
      final response = await HttpClient.post(rota, body: problema.toJson());

      if (response.statusCode != 201) {
        throw Exception('Erro ao criar problema: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao criar problema');
    }
  }

  static Future<void> putProblema(Problem problema) async {
    if (problema.id == null) {
      throw Exception('ID do problema é obrigatório para atualização.');
    }

    try {
      final response = await HttpClient.put('$rota/${problema.id}', body: problema.toJson());

      if (response.statusCode != 200) {
        throw Exception('Erro ao atualizar problema: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar problema');
    }
  }

  static Future<void> deleteProblema(int id) async {
    try {
      final response = await HttpClient.delete('/$rota/$id');

      if (response.statusCode != 204) {
        throw Exception('Erro ao deletar problema: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao deletar problema');
    }
  }
}
