import 'package:flutter_pandyzer/structure/http/models/ApplicationType.dart';
import 'package:flutter_pandyzer/structure/http/models/Status.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';

abstract class AvaliacoesEvent {}

class LoadAvaliacoesEvent extends AvaliacoesEvent {}

class AddAvaliacaoEvent extends AvaliacoesEvent {
  final String avaliacao;

  AddAvaliacaoEvent(this.avaliacao);
}

class LoadCamposCadastroAvaliacao extends AvaliacoesEvent {}

class ApplyFiltersEvent extends AvaliacoesEvent {
  final String? description;
  final String? startDate;
  final String? finalDate;
  final Status? status;

  ApplyFiltersEvent({
    this.description,
    this.startDate,
    this.finalDate,
    this.status,
  });
}

class CadastrarAvaliacaoEvent extends AvaliacoesEvent {
  String descricao;
  String link;
  String dataInicio;
  String dataFim;
  ApplicationType tipoAplicacao;
  List<String> objetivos;
  List<User> avaliadores;
  bool isPublic;
  int limit;

  CadastrarAvaliacaoEvent({
    required this.descricao,
    required this.link,
    required this.dataInicio,
    required this.dataFim,
    required this.tipoAplicacao,
    required this.objetivos,
    required this.avaliadores,
    required this.isPublic,
    required this.limit,
  });
}

class LoadEvaluationDetailsEvent extends AvaliacoesEvent {
  final int evaluationId;
  LoadEvaluationDetailsEvent(this.evaluationId);
}

class StartEvaluationEvent extends AvaliacoesEvent {
  final int evaluatorId;
  final int evaluationId;

  StartEvaluationEvent({required this.evaluatorId, required this.evaluationId});
}

class UpdateAvaliacaoEvent extends AvaliacoesEvent {
  final int id;
  final String descricao;
  final String link;
  final String dataInicio;
  final String dataFim;
  final ApplicationType tipoAplicacao;
  final List<String> objetivos;
  final List<User> avaliadores;
  final bool isPublic;
  final int limit;

  UpdateAvaliacaoEvent({
    required this.id,
    required this.descricao,
    required this.link,
    required this.dataInicio,
    required this.dataFim,
    required this.tipoAplicacao,
    required this.objetivos,
    required this.avaliadores,
    required this.isPublic,
    required this.limit,
  });
}

class DeleteAvaliacaoEvent extends AvaliacoesEvent {
  final int evaluationId;
  DeleteAvaliacaoEvent(this.evaluationId);
}

class DeleteEvaluatorAndProblems extends AvaliacoesEvent {
  final int evaluatorId;
  final int evaluationId;
  DeleteEvaluatorAndProblems({required this.evaluatorId, required this.evaluationId});
}