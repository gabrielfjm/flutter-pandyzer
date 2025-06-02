import 'dart:convert';

import 'package:flutter_pandyzer/core/http_client.dart';
import 'package:flutter_pandyzer/structure/http/models/Login.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';

mixin LoginService {

  static String rota = '/login';

  static Future<User> postLogin(String email, String senha) async {
    try {

      Login login = new Login(email: email, senha: senha);
      final response = await HttpClient.post(rota, body: login.toJson());

      if (response.statusCode == 200) { // Login bem-sucedido geralmente retorna 200 OK
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final User usuario = User.fromJson(responseData);
        return usuario;
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception('Erro ao verificar login: ${errorData['message'] ?? response.reasonPhrase}');
      }
      else {
        throw Exception('Erro ao verificar login: ${response.statusCode} ${response.reasonPhrase}');
      }

    } catch (e) {
      throw Exception('Erro ao verificar login');
    }
  }

}