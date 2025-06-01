import 'dart:convert';

import 'package:flutter_pandyzer/core/http_client.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';

mixin UsuarioService {

  static String rota = '/users';

  static Future<List<User>> getUsuarios() async {
    try {
      final response = await HttpClient.get(rota);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => User.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao buscar usuarios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar usuarios');
    }
  }

  static Future<User> getUsuarioById(int id) async {
    try {
      final response = await HttpClient.get('$rota/$id');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Erro ao buscar usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar usuario');
    }
  }

  static Future<void> postUsuario(User usuario) async {
    try {
      final response = await HttpClient.post(rota, body: usuario.toJson());

      if (response.statusCode != 201) {
        throw Exception('Erro ao criar usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao criar usuario');
    }
  }

  static Future<void> putUsuario(User usuario) async {
    if (usuario.id == null) {
      throw Exception('ID do usuario é obrigatório para atualização.');
    }

    try {
      final response = await HttpClient.put('$rota/${usuario.id}', body: usuario.toJson());

      if (response.statusCode != 200) {
        throw Exception('Erro ao atualizar usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar usuario');
    }
  }

  static Future<void> deleteUsuario(int id) async {
    try {
      final response = await HttpClient.delete('/$rota/$id');

      if (response.statusCode != 204) {
        throw Exception('Erro ao deletar usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao deletar usuario');
    }
  }
}
