import 'dart:convert';

import 'package:flutter_pandyzer/core/http_client.dart';
import 'package:flutter_pandyzer/structure/http/models/Status.dart';

mixin StatusService {

  static String rota = '/status';

  static Future<List<Status>> getStatus() async {
    try {
      final response = await HttpClient.get(rota);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Status.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao buscar status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar status');
    }
  }

  static Future<Status> getStatusById(int id) async {
    try {
      final response = await HttpClient.get('$rota/$id');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Status.fromJson(data);
      } else {
        throw Exception('Erro ao buscar status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar status');
    }
  }

  static Future<void> postStatus(Status status) async {
    try {
      final response = await HttpClient.post(rota, body: status.toJson());

      if (response.statusCode != 201) {
        throw Exception('Erro ao criar status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao criar status');
    }
  }

  static Future<void> putStatus(Status status) async {
    if (status.id == null) {
      throw Exception('ID do status é obrigatório para atualização.');
    }

    try {
      final response = await HttpClient.put('$rota/${status.id}', body: status.toJson());

      if (response.statusCode != 200) {
        throw Exception('Erro ao atualizar status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar status');
    }
  }

  static Future<void> deleteStatus(int id) async {
    try {
      final response = await HttpClient.delete('$rota/$id');

      if (response.statusCode != 204) {
        throw Exception('Erro ao deletar status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao deletar status');
    }
  }
}
