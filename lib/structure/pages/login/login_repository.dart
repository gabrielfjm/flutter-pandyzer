import 'package:flutter_pandyzer/structure/http/models/User.dart';
import 'package:flutter_pandyzer/structure/http/services/login_service.dart';

mixin LoginRepository {
  static Future<User> postLogin(String email, String senha) async {
    return await LoginService.postLogin(email, senha);
  }
}