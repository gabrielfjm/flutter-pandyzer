import 'dart:convert';

import 'package:flutter_pandyzer/core/http_client.dart';
import 'package:flutter_pandyzer/structure/http/models/Severity.dart';

mixin SeveridadeService {

  static String rota = '/severities';

  static Future<List<Severity>> getSeveridades() async {
    try {
      final response = await HttpClient.get(rota);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Severity.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao buscar severidades: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar severidades');
    }
  }

  static Future<Severity> getSeveridadeById(int id) async {
    try {
      final response = await HttpClient.get('$rota/$id');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Severity.fromJson(data);
      } else {
        throw Exception('Erro ao buscar severidade: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar severidade');
    }
  }

  static Future<void> postSeveridade(Severity severidade) async {
    try {
      final response = await HttpClient.post(rota, body: severidade.toJson());

      if (response.statusCode != 201) {
        throw Exception('Erro ao criar severidade: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao criar severidade');
    }
  }

  static Future<void> putSeveridade(Severity severidade) async {
    if (severidade.id == null) {
      throw Exception('ID do severidade é obrigatório para atualização.');
    }

    try {
      final response = await HttpClient.put('$rota/${severidade.id}', body: severidade.toJson());

      if (response.statusCode != 200) {
        throw Exception('Erro ao atualizar severidade: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar severidade');
    }
  }

  static Future<void> deleteSeveridade(int id) async {
    try {
      final response = await HttpClient.delete('$rota/$id');

      if (response.statusCode != 204) {
        throw Exception('Erro ao deletar severidade: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao deletar severidade');
    }
  }
}
