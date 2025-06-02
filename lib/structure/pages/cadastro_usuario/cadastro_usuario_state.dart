import 'package:flutter_pandyzer/structure/http/models/UserType.dart';

abstract class CadastroUsuarioState{
  List<UserType> tiposUsuario;
  String? message;

  CadastroUsuarioState({required this.tiposUsuario, this.message});
}

class CadastroUsuarioInitialState extends CadastroUsuarioState {
  CadastroUsuarioInitialState() : super(
    tiposUsuario: [],
  );
}

class CadastroUsuarioLoadingState extends CadastroUsuarioState {
  CadastroUsuarioLoadingState() : super(
    tiposUsuario: [],
  );
}

class CadastroUsuarioLoadSuccesState extends CadastroUsuarioState {
  CadastroUsuarioLoadSuccesState({required super.tiposUsuario});
}

class CadastroUsuarioSuccesState extends CadastroUsuarioState {
  CadastroUsuarioSuccesState() : super(
    tiposUsuario: [],
  );
}

class CadastroUsuarioError extends CadastroUsuarioState {
  CadastroUsuarioError({required super.message}) : super(
    tiposUsuario: [],
  );
}