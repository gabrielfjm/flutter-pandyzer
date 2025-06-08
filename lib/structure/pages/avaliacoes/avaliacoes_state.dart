import 'package:flutter_pandyzer/structure/http/models/ApplicationType.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluator.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';

abstract class AvaliacoesState {
  final List<ApplicationType> dominios;
  final List<Evaluation> avaliacoes;
  final Evaluation? evaluation;
  final List<Objective> objectives;
  final List<Evaluator> evaluators;
  final List<User> availableEvaluators;

  AvaliacoesState({
    this.dominios = const [],
    this.avaliacoes = const [],
    this.evaluation,
    this.objectives = const [],
    this.evaluators = const [],
    this.availableEvaluators = const [],
  });
}

class AvaliacoesInitial extends AvaliacoesState {}

class AvaliacoesLoading extends AvaliacoesState {
  AvaliacoesLoading({AvaliacoesState? oldState})
      : super(
    avaliacoes: oldState?.avaliacoes ?? [],
    dominios: oldState?.dominios ?? [],
    availableEvaluators: oldState?.availableEvaluators ?? [],
  );
}

class AvaliacoesLoaded extends AvaliacoesState {
  AvaliacoesLoaded({required List<Evaluation> avaliacoes})
      : super(avaliacoes: avaliacoes);
}

class AvaliacaoCamposLoaded extends AvaliacoesState {
  AvaliacaoCamposLoaded({
    required List<ApplicationType> dominios,
    required List<User> availableEvaluators,
  }) : super(
    dominios: dominios,
    availableEvaluators: availableEvaluators,
  );
}

class EvaluationDetailsLoaded extends AvaliacoesState {
  EvaluationDetailsLoaded({
    required Evaluation evaluation,
    required List<Objective> objectives,
    required List<Evaluator> evaluators,
    required List<ApplicationType> dominios,
    required List<Evaluation> avaliacoes,
    required List<User> availableEvaluators,
  }) : super(
    evaluation: evaluation,
    objectives: objectives,
    evaluators: evaluators,
    dominios: dominios,
    avaliacoes: avaliacoes,
    availableEvaluators: availableEvaluators,
  );
}

class AvaliacaoCadastrada extends AvaliacoesState {}
class AvaliacaoUpdated extends AvaliacoesState {}
class AvaliacaoDeleted extends AvaliacoesState {
  AvaliacaoDeleted({required List<Evaluation> avaliacoes}) : super(avaliacoes: avaliacoes);
}

class AvaliacoesError extends AvaliacoesState {
  final String? message;
  AvaliacoesError({this.message});
}