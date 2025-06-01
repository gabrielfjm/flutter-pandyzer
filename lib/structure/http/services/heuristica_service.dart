import 'dart:convert';

import 'package:flutter_pandyzer/core/http_client.dart';
import 'package:flutter_pandyzer/structure/http/models/Heuristic.dart';

mixin HeuristicaService {

  static String rota = '/heuristics';

  static Future<List<Heuristic>> getHeuristicas() async {
    try {
      final response = await HttpClient.get(rota);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Heuristic.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao buscar heuristicas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar heuristicas');
    }
  }

  static Future<Heuristic> getHeuristicaById(int id) async {
    try {
      final response = await HttpClient.get('$rota/$id');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Heuristic.fromJson(data);
      } else {
        throw Exception('Erro ao buscar heuristica: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar heuristica');
    }
  }

  static Future<void> postHeuristica(Heuristic heuristica) async {
    try {
      final response = await HttpClient.post(rota, body: heuristica.toJson());

      if (response.statusCode != 201) {
        throw Exception('Erro ao criar heuristica: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao criar heuristica');
    }
  }

  static Future<void> putHeuristica(Heuristic heuristica) async {
    if (heuristica.id == null) {
      throw Exception('ID do heuristica é obrigatório para atualização.');
    }

    try {
      final response = await HttpClient.put('$rota/${heuristica.id}', body: heuristica.toJson());

      if (response.statusCode != 200) {
        throw Exception('Erro ao atualizar heuristica: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar heuristica');
    }
  }

  static Future<void> deleteHeuristica(int id) async {
    try {
      final response = await HttpClient.delete('/$rota/$id');

      if (response.statusCode != 204) {
        throw Exception('Erro ao deletar heuristica: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao deletar heuristica');
    }
  }
}
