import 'dart:convert';
import 'package:flutter_pandyzer/core/http_client.dart';
import 'package:flutter_pandyzer/structure/http/models/Log.dart';

mixin LogService {
  static String rota = '/logs';

  /// Busca os logs de atividades relacionados às avaliações que um usuário criou.
  static Future<List<Log>> getActivityLogsByCreatorId(int userId) async {
    try {
      final response = await HttpClient.get('$rota/user/$userId');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((item) => Log.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao buscar logs de atividade: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar logs de atividade: $e');
    }
  }

  /// Busca todos os logs do sistema.
  static Future<List<Log>> getLogs() async {
    try {
      final response = await HttpClient.get(rota);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((item) => Log.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao buscar logs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar logs: $e');
    }
  }

  /// Busca um log específico pelo ID.
  static Future<Log> getLogById(int id) async {
    try {
      final response = await HttpClient.get('$rota/$id');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return Log.fromJson(data);
      } else {
        throw Exception('Erro ao buscar log: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar log: $e');
    }
  }

  /// Cria um novo registro de log.
  static Future<Log> postLog(Log log) async {
    try {
      final response = await HttpClient.post(rota, body: log.toJson());

      if (response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return Log.fromJson(data);
      } else {
        throw Exception('Erro ao criar log: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao criar log: $e');
    }
  }

  /// Atualiza um registro de log.
  static Future<void> putLog(Log log) async {
    if (log.id == null) {
      throw Exception('ID do log é obrigatório para atualização.');
    }

    try {
      final response = await HttpClient.put('$rota/${log.id}', body: log.toJson());

      if (response.statusCode != 200) {
        throw Exception('Erro ao atualizar log: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar log: $e');
    }
  }

  /// Deleta um registro de log.
  static Future<void> deleteLog(int id) async {
    try {
      final response = await HttpClient.delete('$rota/$id');

      if (response.statusCode != 204) {
        throw Exception('Erro ao deletar log: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao deletar log: $e');
    }
  }
}