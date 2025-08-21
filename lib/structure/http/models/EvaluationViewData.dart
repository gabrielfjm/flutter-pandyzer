import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluator.dart';

/// Uma classe ViewModel para agrupar todos os dados necessários
/// para renderizar um card de avaliação na UI.
class EvaluationViewData {
  final Evaluation evaluation;

  // Armazena o objeto Evaluator completo do usuário logado, se ele for um avaliador.
  // Fica nulo se o usuário logado não for um avaliador nesta avaliação.
  final Evaluator? currentUserAsEvaluator;

  EvaluationViewData({
    required this.evaluation,
    this.currentUserAsEvaluator,
  });

  /// Getter para verificar facilmente se o usuário logado já iniciou sua avaliação.
  /// Retorna 'false' se ele não for um avaliador ou se o status for "Não Iniciada" (ID 3).
  bool get currentUserHasStarted {
    if (currentUserAsEvaluator == null) {
      return false;
    }
    return currentUserAsEvaluator!.status?.id != 3;
  }
}