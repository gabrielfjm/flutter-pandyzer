import 'dart:convert';

import 'package:flutter_pandyzer/core/http_client.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';

mixin ObjetivoService {

  static String rota = '/objectives';

  static Future<List<Objective>> getObjetivos() async {
    try {
      final response = await HttpClient.get(rota);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Objective.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao buscar objetivos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar objetivos');
    }
  }

  static Future<Objective> getObjetivoById(int id) async {
    try {
      final response = await HttpClient.get('$rota/$id');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Objective.fromJson(data);
      } else {
        throw Exception('Erro ao buscar objetivo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar objetivo');
    }
  }

  static Future<void> postObjetivo(Objective objetivo) async {
    try {
      final response = await HttpClient.post(rota, body: objetivo.toJson());

      if (response.statusCode != 201) {
        throw Exception('Erro ao criar objetivo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao criar objetivo');
    }
  }

  static Future<void> putObjetivo(Objective objetivo) async {
    if (objetivo.id == null) {
      throw Exception('ID do objetivo é obrigatório para atualização.');
    }

    try {
      final response = await HttpClient.put('$rota/${objetivo.id}', body: objetivo.toJson());

      if (response.statusCode != 200) {
        throw Exception('Erro ao atualizar objetivo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar objetivo');
    }
  }

  static Future<void> deleteObjetivo(int id) async {
    try {
      final response = await HttpClient.delete('$rota/$id');

      if (response.statusCode != 204) {
        throw Exception('Erro ao deletar objetivo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao deletar objetivo');
    }
  }
}
