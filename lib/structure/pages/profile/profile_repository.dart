import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_pandyzer/core/http_client.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';
import 'package:flutter_pandyzer/structure/http/services/usuario_service.dart';

class ProfileRepository {
  ProfileRepository._();

  // ----------------- Usuário atual -----------------
  static Future<User> fetchCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userIdStr = prefs.getString('userId');
    if (userIdStr == null) {
      throw Exception('userId não encontrado no SharedPreferences.');
    }
    final userId = int.tryParse(userIdStr);
    if (userId == null) {
      throw Exception('userId inválido no SharedPreferences.');
    }
    return UsuarioService.getUsuarioById(userId);
  }

  // ----------------- Atualizar perfil -----------------
  static Future<User> updateUser({
    required int userId,
    required String name,
    required String email,
    String? newPassword,
  }) async {
    final payload = User(
      id: userId,
      name: name,
      email: email,
      password: (newPassword != null && newPassword.trim().isNotEmpty)
          ? newPassword.trim()
          : null,
    );
    await UsuarioService.putUsuario(payload);
    return UsuarioService.getUsuarioById(userId);
  }

  // ----------------- Avaliações do usuário -----------------
  /// Busca as avaliações **criadas** pelo usuário logado.
  /// Endpoint correto conforme seu backend: GET /evaluations/creator/{userId}
  static Future<List<Map<String, dynamic>>> fetchMyEvaluations() async {
    final prefs = await SharedPreferences.getInstance();
    final userIdStr = prefs.getString('userId');
    if (userIdStr == null) {
      throw Exception('userId não encontrado no SharedPreferences.');
    }
    final userId = int.tryParse(userIdStr);
    if (userId == null) {
      throw Exception('userId inválido no SharedPreferences.');
    }

    final resp = await HttpClient.get('/evaluations/creator/$userId');
    if (resp.statusCode != 200) {
      throw Exception(
          'Falha ao carregar suas avaliações: HTTP ${resp.statusCode}');
    }

    final List<dynamic> data = jsonDecode(resp.body);
    return data.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }
}
