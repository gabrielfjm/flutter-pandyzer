abstract class CadastroUsuarioEvent {}

class LoadCamposEvent extends CadastroUsuarioEvent{}

class CadastrarEvent extends CadastroUsuarioEvent {
  String nome;
  String email;
  String senha;
  bool isAvaliador;

  CadastrarEvent({required this.nome, required this.email, required this.senha, required this.isAvaliador});
}

class VerificarEmail extends CadastroUsuarioEvent{
  String email;

  VerificarEmail({required this.email});
}
