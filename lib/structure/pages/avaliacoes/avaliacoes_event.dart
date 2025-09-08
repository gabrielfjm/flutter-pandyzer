// lib/structure/pages/avaliacoes/avaliacoes_event.dart
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
  final int? creatorId;   // <- novo
  final Status? status;

  ApplyFiltersEvent({
    this.description,
    this.creatorId,       // <- novo
    this.status,
  });
}


class CadastrarAvaliacaoEvent extends AvaliacoesEvent {
  final String descricao;
  final String link;
  final String dataInicio;
  final String dataFim;
  final ApplicationType tipoAplicacao;
  final List<String> objetivos;
  final List<User> avaliadores;
  final bool isPublic;
  final int limit;

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

/// Iniciar avaliação para um avaliador.
/// IMPORTANTE: aqui é o **id do USUÁRIO** do avaliador, não o id do registro Evaluator.
class StartEvaluationEvent extends AvaliacoesEvent {
  /// ID do registro na tabela Evaluator (evaluator.id)
  final int evaluatorRecordId;

  /// ID do usuário do avaliador (evaluator.user.id)
  final int evaluatorUserId;

  /// ID da avaliação
  final int evaluationId;

  StartEvaluationEvent({
    required this.evaluatorRecordId,
    required this.evaluatorUserId,
    required this.evaluationId,
  });
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

/// Remover avaliador e apagar os problemas dele.
/// Precisamos dos DOIS ids:
/// - evaluatorRecordId: id do registro na tabela Evaluator (para deletar o vínculo)
/// - evaluatorUserId: id do usuário (para buscar/apagar problemas e/ou atualizar status)
class DeleteEvaluatorAndProblems extends AvaliacoesEvent {
  final int evaluatorRecordId; // ex.: evaluator.id!
  final int evaluatorUserId;   // ex.: evaluator.user!.id!
  final int evaluationId;

  DeleteEvaluatorAndProblems({
    required this.evaluatorRecordId,
    required this.evaluatorUserId,
    required this.evaluationId,
  });
}

/// Finalizar avaliação (normalmente statusId = 2).
/// Também usa id do USUÁRIO do avaliador.
class FinalizeEvaluation extends AvaliacoesEvent {
  final int evaluatorUserId;
  final int evaluationId;
  final int statusId; // geralmente 2

  FinalizeEvaluation({
    required this.evaluatorUserId,
    required this.evaluationId,
    this.statusId = 2,
  });
}
