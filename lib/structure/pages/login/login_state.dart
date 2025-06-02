import 'package:flutter_pandyzer/structure/http/models/User.dart';

abstract class LoginState{
  User? usuario;
  String? message;

  LoginState({this.usuario, this.message});
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccesState extends LoginState {
  LoginSuccesState({required super.usuario});
}

class LoginError extends LoginState {
  LoginError({required super.message});
}