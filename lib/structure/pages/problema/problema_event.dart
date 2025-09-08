// Eventos da tela de Problemas

import 'package:flutter_pandyzer/structure/http/models/Problem.dart';

abstract class ProblemaEvent {
  const ProblemaEvent();
}

/// Carrega tudo que a página precisa
class LoadProblemaPageData extends ProblemaEvent {
  final int evaluationId;
  /// id do USUÁRIO avaliador (não é o id do registro Evaluator)
  final int evaluatorUserId;

  const LoadProblemaPageData({
    required this.evaluationId,
    required this.evaluatorUserId,
  });
}

/// Upsert + delete dos problemas
class UpdateProblems extends ProblemaEvent {
  final List<Problem> problemsToUpsert;
  final List<int> problemIdsToDelete;
  final int evaluationId;
  /// id do USUÁRIO avaliador
  final int evaluatorUserId;

  const UpdateProblems({
    required this.problemsToUpsert,
    required this.problemIdsToDelete,
    required this.evaluationId,
    required this.evaluatorUserId,
  });
}

/// Finaliza a avaliação para este usuário avaliador
class FinalizeEvaluation extends ProblemaEvent {
  /// id do USUÁRIO avaliador
  final int evaluatorUserId;
  /// id do status desejado (ex.: 2 = Concluída)
  final int statusId;
  final int evaluationId;

  const FinalizeEvaluation({
    required this.evaluatorUserId,
    required this.statusId,
    required this.evaluationId,
  });
}
