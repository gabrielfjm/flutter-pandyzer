import 'dart:convert';

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

  static Future<void> postAvaliacao(Evaluation avaliacao) async {
    try {
      final response = await HttpClient.post(rota, body: avaliacao.toJson());

      if (response.statusCode != 201) {
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
      final response = await HttpClient.delete('/$rota/$id');

      if (response.statusCode != 204) {
        throw Exception('Erro ao deletar avaliação: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao deletar avaliação');
    }
  }
}
