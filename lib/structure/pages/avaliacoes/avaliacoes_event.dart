import 'package:flutter_pandyzer/structure/http/models/ApplicationType.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';

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
  List<User> avaliadores;

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

class LoadEvaluationDetailsEvent extends AvaliacoesEvent {
  final int evaluationId;
  LoadEvaluationDetailsEvent(this.evaluationId);
}

class UpdateAvaliacaoEvent extends AvaliacoesEvent {
  final int id;
  final String descricao;
  final String link;
  final String dataInicio;
  final String dataFim;
  final ApplicationType tipoAplicacao;
  final List<String> objetivos;
  final List<User> avaliadores; // Adicionado

  UpdateAvaliacaoEvent({
    required this.id,
    required this.descricao,
    required this.link,
    required this.dataInicio,
    required this.dataFim,
    required this.tipoAplicacao,
    required this.objetivos,
    required this.avaliadores, // Adicionado
  });
}

class DeleteAvaliacaoEvent extends AvaliacoesEvent {
  final int evaluationId;
  DeleteAvaliacaoEvent(this.evaluationId);
}