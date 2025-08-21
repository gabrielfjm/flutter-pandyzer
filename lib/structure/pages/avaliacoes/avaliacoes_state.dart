import 'package:flutter_pandyzer/structure/http/models/ApplicationType.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/EvaluationViewData.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluator.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';

// --- CLASSE BASE ATUALIZADA ---
abstract class AvaliacoesState {
  // Dados que podem persistir entre os estados
  final List<EvaluationViewData> myEvaluations;
  final List<EvaluationViewData> communityEvaluations;
  final Evaluation? evaluation;

  // Dados específicos de outras telas/modais
  final List<ApplicationType> dominios;
  final List<Objective> objectives;
  final List<Evaluator> evaluators;
  final List<User> availableEvaluators;

  AvaliacoesState({
    this.myEvaluations = const [],
    this.communityEvaluations = const [],
    this.evaluation,
    this.dominios = const [],
    this.objectives = const [],
    this.evaluators = const [],
    this.availableEvaluators = const [],
  });
}

class AvaliacoesInitial extends AvaliacoesState {}

// --- ESTADO DE LOADING ATUALIZADO ---
class AvaliacoesLoading extends AvaliacoesState {
  // O construtor agora copia os dados do estado anterior
  AvaliacoesLoading({AvaliacoesState? oldState})
      : super(
    myEvaluations: oldState?.myEvaluations ?? [],
    communityEvaluations: oldState?.communityEvaluations ?? [],
    evaluation: oldState?.evaluation,
    dominios: oldState?.dominios ?? [],
    objectives: oldState?.objectives ?? [],
    evaluators: oldState?.evaluators ?? [],
    availableEvaluators: oldState?.availableEvaluators ?? [],
  );
}

// --- ESTADO DE CARREGADO ATUALIZADO ---
class AvaliacoesLoaded extends AvaliacoesState {
  AvaliacoesLoaded({
    required List<EvaluationViewData> myEvaluations,
    required List<EvaluationViewData> communityEvaluations,
  }) : super(
    myEvaluations: myEvaluations,
    communityEvaluations: communityEvaluations,
  );
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
    required List<EvaluationViewData> myEvaluations, // Mantém os dados da lista principal
    required List<EvaluationViewData> communityEvaluations,
    required List<User> availableEvaluators,
  }) : super(
    evaluation: evaluation,
    objectives: objectives,
    evaluators: evaluators,
    dominios: dominios,
    myEvaluations: myEvaluations,
    communityEvaluations: communityEvaluations,
    availableEvaluators: availableEvaluators,
  );
}

class AvaliacaoCadastrada extends AvaliacoesState {}
class AvaliacaoUpdated extends AvaliacoesState {}

class AvaliacaoDeleted extends AvaliacoesState {
  AvaliacaoDeleted({
    required List<EvaluationViewData> myEvaluations,
    required List<EvaluationViewData> communityEvaluations,
  }) : super(
    myEvaluations: myEvaluations,
    communityEvaluations: communityEvaluations,
  );
}

class AvaliacoesError extends AvaliacoesState {
  final String? message;
  AvaliacoesError({this.message});
}