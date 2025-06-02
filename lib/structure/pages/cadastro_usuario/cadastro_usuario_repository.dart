import 'package:flutter_pandyzer/structure/http/models/User.dart';
import 'package:flutter_pandyzer/structure/http/models/UserType.dart';
import 'package:flutter_pandyzer/structure/http/services/tipo_usuario_service.dart';
import 'package:flutter_pandyzer/structure/http/services/usuario_service.dart';

mixin CadastroUsuarioRepository{

  static Future<void> postUsuario(String nome, String email, String senha, UserType tipoUsuario){
    User usuario = new User(name: nome, email: email, password: senha, active: 1, userType: tipoUsuario);
    return UsuarioService.postUsuario(usuario);
  }

  static Future<List<UserType>> getUsersTypes(){
    return TipoUsuarioService.getTipoUsuarios();
  }

  static Future<UserType> getUserTypeById(int idTipoUsuario){
    return TipoUsuarioService.getTipoUsuarioById(idTipoUsuario);
  }

  static Future<bool> verificaEmail(String email){
    return UsuarioService.getEmail(email);
  }

}