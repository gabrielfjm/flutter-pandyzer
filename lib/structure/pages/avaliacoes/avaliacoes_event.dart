import 'package:flutter_pandyzer/structure/http/models/ApplicationType.dart';

abstract class AvaliacoesEvent {}

class LoadAvaliacoesEvent extends AvaliacoesEvent {}

class AddAvaliacaoEvent extends AvaliacoesEvent {
  final String avaliacao;

  AddAvaliacaoEvent(this.avaliacao);
}

class LoadCamposCadastroAvaliacao extends AvaliacoesEvent {}

class CadastrarAvaliacaoEvent extends AvaliacoesEvent {
  String descricao;
  String link;
  String dataInicio;
  String dataFim;
  ApplicationType tipoAplicacao;
  List<String> objetivos;
  List<String> avaliadores;

  CadastrarAvaliacaoEvent({
    required this.descricao,
    required this.link,
    required this.dataInicio,
    required this.dataFim,
    required this.tipoAplicacao,
    required this.objetivos,
    required this.avaliadores,
  });
}
