import 'package:flutter_pandyzer/structure/http/models/Problem.dart';

abstract class ProblemaEvent {}

class LoadProblemaPageData extends ProblemaEvent {
  final int evaluationId;
  final int evaluatorId;

  LoadProblemaPageData({required this.evaluationId, required this.evaluatorId});
}

class SaveProblemas extends ProblemaEvent {
  final Map<int, List<Problem>> problemsToSave;
  SaveProblemas(this.problemsToSave);
}