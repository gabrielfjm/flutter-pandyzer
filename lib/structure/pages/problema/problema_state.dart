import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/Heuristic.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/http/models/Severity.dart';

abstract class ProblemaState {
  final Evaluation? evaluation;
  final List<Objective> objectives;
  final List<Heuristic> heuristics;
  final List<Severity> severities;

  const ProblemaState({
    this.evaluation,
    this.objectives = const [],
    this.heuristics = const [],
    this.severities = const [],
  });
}

class ProblemaInitial extends ProblemaState {}

class ProblemaLoading extends ProblemaState {}

class ProblemaLoaded extends ProblemaState {
  const ProblemaLoaded({
    required Evaluation evaluation,
    required List<Objective> objectives,
    required List<Heuristic> heuristics,
    required List<Severity> severities,
  }) : super(
    evaluation: evaluation,
    objectives: objectives,
    heuristics: heuristics,
    severities: severities,
  );
}

class ProblemaSaveSuccess extends ProblemaState {}

class ProblemaError extends ProblemaState {
  final String message;
  const ProblemaError(this.message);
}