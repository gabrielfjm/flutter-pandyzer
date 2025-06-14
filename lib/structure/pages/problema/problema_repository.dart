import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/Heuristic.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/http/models/Problem.dart';
import 'package:flutter_pandyzer/structure/http/models/Severity.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';
import 'package:flutter_pandyzer/structure/http/services/avaliacao_service.dart';
import 'package:flutter_pandyzer/structure/http/services/avaliador_service.dart';
import 'package:flutter_pandyzer/structure/http/services/heuristica_service.dart';
import 'package:flutter_pandyzer/structure/http/services/objetivo_service.dart';
import 'package:flutter_pandyzer/structure/http/services/problema_service.dart';
import 'package:flutter_pandyzer/structure/http/services/severidade_service.dart';
import 'package:flutter_pandyzer/structure/http/services/usuario_service.dart';

mixin ProblemaRepository {

  static Future<Evaluation> getAvaliacoesById(int id) async {
    return await AvaliacaoService.getAvaliacaoById(id);
  }

  static Future<List<Objective>> getObjectivesByEvaluationId(int idEvalution) async {
    return await ObjetivoService.getObjetivoByIdAvaliacao(idEvalution);
  }

  static Future<List<Heuristic>> getHeuristics() async {
    return await HeuristicaService.getHeuristicas();
  }

  static Future<List<Severity>> getSeverities() async {
    return await SeveridadeService.getSeveridades();
  }

  static Future<User> getUsuarioById(int id) async {
    return await UsuarioService.getUsuarioById(id);
  }

  static Future<void> createProblema(Problem problema) async {
    return await ProblemaService.postProblema(problema);
  }

  static Future<List<Problem>> getProblemsByIdObjetivoAndIdEvaluator(int idObjetivo, int idEvaluator) async {
    return await ProblemaService.getProblemsByIdObjetivoAndIdEvaluator(idObjetivo, idEvaluator);
  }

  static Future<void> updateEvaluatorStatus(int usuarioId, int statusId, int evaluationId) async {
    return await AvaliadorService.updateEvaluatorStatus(usuarioId, statusId, evaluationId);
  }

}