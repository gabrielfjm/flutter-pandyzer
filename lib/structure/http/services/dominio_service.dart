import 'dart:convert';

import 'package:flutter_pandyzer/core/http_client.dart';
import 'package:flutter_pandyzer/structure/http/models/ApplicationType.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';

mixin DominioService {

  static String rota = '/applicationtype';

  static Future<List<ApplicationType>> getDominios() async {
    try {
      final response = await HttpClient.get(rota);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => ApplicationType.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao buscar dominios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar dominios');
    }
  }

  static Future<ApplicationType> getDominioById(int id) async {
    try {
      final response = await HttpClient.get('$rota/$id');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApplicationType.fromJson(data);
      } else {
        throw Exception('Erro ao buscar domínio: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar domínio');
    }
  }

  static Future<void> postDominio(ApplicationType dominio) async {
    try {
      final response = await HttpClient.post(rota, body: dominio.toJson());

      if (response.statusCode != 201) {
        throw Exception('Erro ao criar domínio: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao criar domínio');
    }
  }

  static Future<void> putDominio(Evaluation dominio) async {
    if (dominio.id == null) {
      throw Exception('ID do domínio é obrigatório para atualização.');
    }

    try {
      final response = await HttpClient.put('$rota/${dominio.id}', body: dominio.toJson());

      if (response.statusCode != 200) {
        throw Exception('Erro ao atualizar domínio: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar domínio');
    }
  }

  static Future<void> deleteDominio(int id) async {
    try {
      final response = await HttpClient.delete('$rota/$id');

      if (response.statusCode != 204) {
        throw Exception('Erro ao deletar dominio: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao deletar dominio');
    }
  }
}
