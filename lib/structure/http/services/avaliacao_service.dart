import 'dart:convert';

import 'package:flutter_pandyzer/core/app_convert.dart';
import 'package:flutter_pandyzer/core/http_client.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';

mixin AvaliacaoService {

  static String rota = '/evaluations';

  static Future<List<Evaluation>> getAvaliacoes() async {
    try {
      final response = await HttpClient.get(rota);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Evaluation.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao buscar avaliações: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar avaliações');
    }
  }

  static Future<Evaluation> getAvaliacaoById(int id) async {
    try {
      final response = await HttpClient.get('$rota/$id');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Evaluation.fromJson(data);
      } else {
        throw Exception('Erro ao buscar avaliação: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar avaliação');
    }
  }

  static Future<Evaluation> postAvaliacao(Evaluation avaliacao) async {
    try {
      final response = await HttpClient.post(rota, body: avaliacao.toJson());

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Evaluation.fromJson(data);
      } else {
        throw Exception('Erro ao criar avaliação: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao criar avaliação');
    }
  }

  static Future<void> putAvaliacao(Evaluation avaliacao) async {
    if (avaliacao.id == null) {
      throw Exception('ID da avaliação é obrigatório para atualização.');
    }

    try {
      final response = await HttpClient.put('$rota/${avaliacao.id}', body: avaliacao.toJson());

      if (response.statusCode != 200) {
        throw Exception('Erro ao atualizar avaliação: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar avaliação');
    }
  }

  static Future<void> deleteAvaliacao(int id) async {
    try {
      final response = await HttpClient.delete('$rota/$id');

      if (response.statusCode != 204) {
        throw Exception('Erro ao deletar avaliação: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao deletar avaliação');
    }
  }

  static Future<List<Evaluation>> getCommunityEvaluations(int userId) async {
    try {
      final response = await HttpClient.get('$rota/community/$userId');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((item) => Evaluation.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao buscar avaliações da comunidade: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar avaliações da comunidade: $e');
    }
  }

  static Future<List<Evaluation>> filterEvaluations({
    String? description,
    String? startDate,
    String? finalDate,
    int? statusId,
  }) async {
    // 1. Cria um mapa vazio
    final Map<String, String> queryParams = {};

    // 2. Adiciona os parâmetros condicionalmente
    if (description != null && description.isNotEmpty) {
      queryParams['description'] = description;
    }
    if (startDate != null && startDate.isNotEmpty) {
      final isoDate = AppConvert.convertDateToIso(startDate);
      // Só adiciona ao mapa se a conversão for bem-sucedida (não nula)
      if (isoDate != null) {
        queryParams['startDate'] = isoDate;
      }
    }
    if (finalDate != null && finalDate.isNotEmpty) {
      final isoDate = AppConvert.convertDateToIso(finalDate);
      if (isoDate != null) {
        queryParams['finalDate'] = isoDate;
      }
    }
    if (statusId != null) {
      queryParams['statusId'] = statusId.toString();
    }

    final uri = Uri.parse('$rota/filter').replace(queryParameters: queryParams);

    try {
      final response = await HttpClient.get(uri.toString());
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((item) => Evaluation.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao filtrar avaliações: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao filtrar avaliações: $e');
    }
  }
}
