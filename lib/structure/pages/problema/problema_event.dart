import 'package:flutter_pandyzer/structure/http/models/Problem.dart';

abstract class ProblemaEvent {}

class LoadProblemaPageData extends ProblemaEvent {
  final int evaluationId;
  LoadProblemaPageData(this.evaluationId);
}

class SaveProblemas extends ProblemaEvent {
  final Map<int, List<Problem>> problemsToSave;
  SaveProblemas(this.problemsToSave);
}