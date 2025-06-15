import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/Heuristic.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/http/models/Problem.dart';
import 'package:flutter_pandyzer/structure/http/models/Severity.dart';

abstract class ProblemaState {
  final Evaluation? evaluation;
  final List<Objective> objectives;
  final List<Heuristic> heuristics;
  final List<Severity> severities;
  final List<Problem> initialProblems;
  final int? currentUserStatusId;

  const ProblemaState({
    this.evaluation,
    this.objectives = const [],
    this.heuristics = const [],
    this.severities = const [],
    this.initialProblems = const [],
    this.currentUserStatusId,
  });
}

class ProblemaInitial extends ProblemaState {}

class ProblemaLoading extends ProblemaState {
  ProblemaLoading({ProblemaState? oldState})
      : super(
    evaluation: oldState?.evaluation,
    objectives: oldState?.objectives ?? [],
    heuristics: oldState?.heuristics ?? [],
    severities: oldState?.severities ?? [],
    initialProblems: oldState?.initialProblems ?? [],
    currentUserStatusId: oldState?.currentUserStatusId,
  );
}

class ProblemaLoaded extends ProblemaState {
  const ProblemaLoaded({
    required Evaluation evaluation,
    required List<Objective> objectives,
    required List<Heuristic> heuristics,
    required List<Severity> severities,
    required List<Problem> initialProblems,
    required int? currentUserStatusId,
  }) : super(
    evaluation: evaluation,
    objectives: objectives,
    heuristics: heuristics,
    severities: severities,
    initialProblems: initialProblems,
    currentUserStatusId: currentUserStatusId,
  );
}

// --- ESTADO CORRIGIDO ---
// Adicionado construtor para carregar os dados e manter a tela consistente ao exibir o Toast de sucesso.
class ProblemaSaveSuccess extends ProblemaState {
  const ProblemaSaveSuccess({
    Evaluation? evaluation,
    List<Objective> objectives = const [],
    List<Heuristic> heuristics = const [],
    List<Severity> severities = const [],
    List<Problem> initialProblems = const [],
    int? currentUserStatusId,
  }) : super(
    evaluation: evaluation,
    objectives: objectives,
    heuristics: heuristics,
    severities: severities,
    initialProblems: initialProblems,
    currentUserStatusId: currentUserStatusId,
  );
}

class ProblemaFinalizeSuccess extends ProblemaState {
  const ProblemaFinalizeSuccess() : super();
}

class ProblemaError extends ProblemaState {
  final String message;
  const ProblemaError(this.message);
}