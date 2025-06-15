import 'package:flutter_pandyzer/structure/http/models/Problem.dart';

abstract class ProblemaEvent {}

class LoadProblemaPageData extends ProblemaEvent {
  final int evaluationId;
  final int evaluatorId;

  LoadProblemaPageData({required this.evaluationId, required this.evaluatorId});
}

class UpdateProblems extends ProblemaEvent {
  final List<Problem> problemsToUpsert; // Upsert = Update or Insert
  final List<int> problemIdsToDelete;
  final int evaluationId;
  final int evaluatorId;

  UpdateProblems({
    required this.problemsToUpsert,
    required this.problemIdsToDelete,
    required this.evaluationId,
    required this.evaluatorId,
  });
}

class FinalizeEvaluation extends ProblemaEvent {
  final int evaluatorId;
  final int statusId;
  final int evaluationId;
  FinalizeEvaluation({required this.evaluatorId, required this.statusId, required this.evaluationId});
}