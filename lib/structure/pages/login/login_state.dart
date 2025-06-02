import 'package:flutter_pandyzer/structure/http/models/User.dart';

abstract class LoginState{}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccesState extends LoginState {
  User usuario;

  LoginSuccesState(this.usuario);
}

class LoginError extends LoginState {
  String message;

  LoginError(this.message);
}