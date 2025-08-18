import 'Evaluation.dart';

class EvaluationViewData {
  final Evaluation evaluation;
  final int? currentUserStatusId;

  EvaluationViewData({
    required this.evaluation,
    this.currentUserStatusId,
  });

  bool get hasStarted => currentUserStatusId != 3 && currentUserStatusId != null;
}