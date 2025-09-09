import 'dart:convert';
import 'package:flutter_pandyzer/core/http_client.dart';
import 'package:flutter_pandyzer/structure/http/models/Login.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';

class LoginException implements Exception {
  final String message;
  LoginException(this.message);
  @override
  String toString() => message;
}

mixin LoginService {
  static const String rota = '/login';

  static Future<User> postLogin(String email, String senha) async {
    try {
      final login = Login(email: email, senha: senha);

      final response = await HttpClient.post(
        rota,
        body: login.toJson(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return User.fromJson(data);
      }

      // ---- tenta extrair mensagem do backend (JSON ou texto puro) ----
      String backendMsg = '';
      // 1) tenta JSON
      try {
        final Map<String, dynamic> err = jsonDecode(response.body);
        backendMsg = (err['message'] ?? err['error'] ?? '').toString();
      } catch (_) {
        // 2) se não for JSON, usa texto puro
        if (response.body.isNotEmpty) {
          backendMsg = response.body.trim();
        }
      }

      // fallback caso mesmo assim não venha nada
      if (backendMsg.isEmpty) {
        backendMsg = 'Erro ao verificar login (${response.statusCode}).';
      }

      // mapeia por status sem sobrescrever a msg do backend
      switch (response.statusCode) {
        case 400:
        case 401:
        case 404:
          throw LoginException(backendMsg);
        default:
          throw LoginException(backendMsg);
      }
    } on LoginException {
      rethrow;
    } catch (_) {
      throw LoginException(
        'Não foi possível concluir o login. Verifique sua conexão e tente novamente.',
      );
    }
  }
}
