// Estados da tela de Problemas

import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/Heuristic.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/http/models/Problem.dart';
import 'package:flutter_pandyzer/structure/http/models/Severity.dart';

abstract class ProblemaState {
  const ProblemaState();

  Evaluation? get evaluation => null;
  List<Objective> get objectives => const [];
  List<Heuristic>? get heuristics => null;
  List<Severity>? get severities => null;
  List<Problem>? get initialProblems => null;
  /// status do usuário avaliador nesta avaliação (ex.: 1 Em andamento, 2 Concluída)
  int? get currentUserStatusId => null;
}

class ProblemaInitial extends ProblemaState {
  const ProblemaInitial();
}

class ProblemaLoading extends ProblemaState {
  final Evaluation? evaluation_;
  final List<Objective> objectives_;
  final List<Heuristic> heuristics_;
  final List<Severity> severities_;
  final List<Problem> initialProblems_;
  final int? currentUserStatusId_;

  /// Construtor “cheio”
  const ProblemaLoading({
    required Evaluation? evaluation,
    required List<Objective> objectives,
    required List<Heuristic> heuristics,
    required List<Severity> severities,
    required List<Problem> initialProblems,
    required int? currentUserStatusId,
  })  : evaluation_ = evaluation,
        objectives_ = objectives,
        heuristics_ = heuristics,
        severities_ = severities,
        initialProblems_ = initialProblems,
        currentUserStatusId_ = currentUserStatusId;

  /// Atalho: reaproveita dados do estado anterior (quando existir)
  factory ProblemaLoading.fromOld(ProblemaState old) {
    return ProblemaLoading(
      evaluation: old.evaluation,
      objectives: old.objectives,
      heuristics: old.heuristics ?? const [],
      severities: old.severities ?? const [],
      initialProblems: old.initialProblems ?? const [],
      currentUserStatusId: old.currentUserStatusId,
    );
  }

  @override
  Evaluation? get evaluation => evaluation_;
  @override
  List<Objective> get objectives => objectives_;
  @override
  List<Heuristic> get heuristics => heuristics_;
  @override
  List<Severity> get severities => severities_;
  @override
  List<Problem> get initialProblems => initialProblems_;
  @override
  int? get currentUserStatusId => currentUserStatusId_;
}

class ProblemaLoaded extends ProblemaState {
  final Evaluation evaluation_;
  final List<Objective> objectives_;
  final List<Heuristic> heuristics_;
  final List<Severity> severities_;
  final List<Problem> initialProblems_;
  final int? currentUserStatusId_;

  const ProblemaLoaded({
    required this.evaluation_,
    required this.objectives_,
    required this.heuristics_,
    required this.severities_,
    required this.initialProblems_,
    required this.currentUserStatusId_,
  });

  @override
  Evaluation get evaluation => evaluation_;
  @override
  List<Objective> get objectives => objectives_;
  @override
  List<Heuristic> get heuristics => heuristics_;
  @override
  List<Severity> get severities => severities_;
  @override
  List<Problem> get initialProblems => initialProblems_;
  @override
  int? get currentUserStatusId => currentUserStatusId_;
}

class ProblemaSaveSuccess extends ProblemaLoaded {
  const ProblemaSaveSuccess({
    required super.evaluation_,
    required super.objectives_,
    required super.heuristics_,
    required super.severities_,
    required super.initialProblems_,
    required super.currentUserStatusId_,
  });
}

class ProblemaFinalizeSuccess extends ProblemaState {
  const ProblemaFinalizeSuccess();
}

class ProblemaError extends ProblemaState {
  final String message_;
  final Evaluation? evaluation_;
  final List<Objective> objectives_;
  final List<Heuristic> heuristics_;
  final List<Severity> severities_;
  final List<Problem> initialProblems_;
  final int? currentUserStatusId_;

  const ProblemaError({
    required String message,
    Evaluation? evaluation,
    List<Objective>? objectives,
    List<Heuristic>? heuristics,
    List<Severity>? severities,
    List<Problem>? initialProblems,
    int? currentUserStatusId,
  })  : message_ = message,
        evaluation_ = evaluation,
        objectives_ = objectives ?? const [],
        heuristics_ = heuristics ?? const [],
        severities_ = severities ?? const [],
        initialProblems_ = initialProblems ?? const [],
        currentUserStatusId_ = currentUserStatusId;

  String get message => message_;
  @override
  Evaluation? get evaluation => evaluation_;
  @override
  List<Objective> get objectives => objectives_;
  @override
  List<Heuristic> get heuristics => heuristics_;
  @override
  List<Severity> get severities => severities_;
  @override
  List<Problem> get initialProblems => initialProblems_;
  @override
  int? get currentUserStatusId => currentUserStatusId_;
}
