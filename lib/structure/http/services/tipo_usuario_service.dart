import 'dart:convert';

import 'package:flutter_pandyzer/core/http_client.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';
import 'package:flutter_pandyzer/structure/http/models/UserType.dart';

mixin TipoUsuarioService {

  static String rota = '/usertype';

  static Future<List<UserType>> getTipoUsuarios() async {
    try {
      final response = await HttpClient.get(rota);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => UserType.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao buscar tipo usuarios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar tipo usuarios');
    }
  }

  static Future<UserType> getTipoUsuarioById(int id) async {
    try {
      final response = await HttpClient.get('$rota/$id');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserType.fromJson(data);
      } else {
        throw Exception('Erro ao buscar tipo usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar tipo usuario');
    }
  }

  static Future<void> postTipoUsuario(User tipoUsuario) async {
    try {
      final response = await HttpClient.post(rota, body: tipoUsuario.toJson());

      if (response.statusCode != 201) {
        throw Exception('Erro ao criar tipo usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao criar tipo usuario');
    }
  }

  static Future<void> putTipoUsuario(User tipoUsuario) async {
    if (tipoUsuario.id == null) {
      throw Exception('ID do tipo usuario é obrigatório para atualização.');
    }

    try {
      final response = await HttpClient.put('$rota/${tipoUsuario.id}', body: tipoUsuario.toJson());

      if (response.statusCode != 200) {
        throw Exception('Erro ao atualizar tipo usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar tipo usuario');
    }
  }

  static Future<void> deleteTipoUsuario(int id) async {
    try {
      final response = await HttpClient.delete('/$rota/$id');

      if (response.statusCode != 204) {
        throw Exception('Erro ao deletar tipo usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao deletar tipo usuario');
    }
  }
}
