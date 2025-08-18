import 'package:flutter_pandyzer/structure/http/models/ApplicationType.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluator.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/http/models/Problem.dart';
import 'package:flutter_pandyzer/structure/http/models/Status.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';
import 'package:flutter_pandyzer/structure/http/services/avaliacao_service.dart';
import 'package:flutter_pandyzer/structure/http/services/avaliador_service.dart';
import 'package:flutter_pandyzer/structure/http/services/dominio_service.dart';
import 'package:flutter_pandyzer/structure/http/services/objetivo_service.dart';
import 'package:flutter_pandyzer/structure/http/services/problema_service.dart';
import 'package:flutter_pandyzer/structure/http/services/status_service.dart';
import 'package:flutter_pandyzer/structure/http/services/usuario_service.dart';

mixin AvaliacoesRepository {

  //AVALIAÇÃO
  static Future<Evaluation> createAvaliacao(Evaluation avaliacao) async {
    return await AvaliacaoService.postAvaliacao(avaliacao);
  }

  static Future<List<Evaluation>> getAvaliacoes() async {
    return await AvaliacaoService.getAvaliacoes();
  }

  static Future<Evaluation> getAvaliacoesById(int id) async {
    return await AvaliacaoService.getAvaliacaoById(id);
  }

  static Future<void> putAvaliacao(Evaluation avaliacao) async {
    return await AvaliacaoService.putAvaliacao(avaliacao);
  }

  static Future<void> deleteAvaliacao(int id) async {
    return await AvaliacaoService.deleteAvaliacao(id);
  }

  //DOMINIO
  static Future<List<ApplicationType>> getDominios() async {
    return await DominioService.getDominios();
  }

  static Future<ApplicationType> getDominioById(int id) async {
    return await DominioService.getDominioById(id);
  }

  //OBEJTIVO
  static Future<void> createObjetivo(Objective objetivo) async {
    return await ObjetivoService.postObjetivo(objetivo);
  }

  static Future<List<Objective>> getObjectivesByEvaluationId(int idEvalution) async{
    return await ObjetivoService.getObjetivoByIdAvaliacao(idEvalution);
  }

  static Future<void> deleteObjetivo (int idObjetivo) async {
    return await ObjetivoService.deleteObjetivo(idObjetivo);
  }

  //USUARIO
  static Future<User> getUsuarioById(int id) async {
    return await UsuarioService.getUsuarioById(id);
  }

  static Future<List<User>> getUsuariosAvaliadores () async {
    return await UsuarioService.getAvaliadores();
  }

  //AVALIADORES
  static Future<void> createAvaliador(Evaluator avaliador) async {
    return await AvaliadorService.postAvaliador(avaliador);
  }

  static Future<List<Evaluator>> getEvaluatorsByIdEvaluation(int idEvaluation) async {
    return await AvaliadorService.getEvaluatorsByIdEvaluation(idEvaluation);
  }

  static Future<void> deleteEvaluator (int id) async {
    return await AvaliadorService.deleteAvaliador(id);
  }

  //STATUS
  static Future<Status> getStatusById(int id) async {
    return await StatusService.getStatusById(id);
  }

  static Future<void> updateEvaluatorStatus(int evaluatorId, int newStatusId) async {

    // final response = await http.put(
    //   Uri.parse('$_baseUrl/evaluators/$evaluatorId/status'),
    //   body: jsonEncode({'statusId': newStatusId}),
    //   headers: {'Content-Type': 'application/json'},
    // );
    //
    // if (response.statusCode != 200) {
    //   throw Exception('Falha ao atualizar o status da avaliação.');
    // }
    // Por enquanto, podemos simular o sucesso
    await Future.delayed(const Duration(milliseconds: 500));
    print('Status do avaliador $evaluatorId atualizado para $newStatusId');
  }

  //PROBLEMA
  static Future<List<Problem>> getProblemsByIdObjetivoAndIdEvaluator(int idObjetivo, int idEvaluator) async {
    return await ProblemaService.getProblemsByIdObjetivoAndIdEvaluator(idObjetivo, idEvaluator);
  }

  static Future<void> deleteProblem (int id) async {
    return await ProblemaService.deleteProblema(id);
  }

}
