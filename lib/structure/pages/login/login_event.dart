abstract class LoginEvent {}

class LogarEvent extends LoginEvent {
  String email;
  String senha;

  LogarEvent({required this.email, required this.senha});
}