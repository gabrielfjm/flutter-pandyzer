import 'package:flutter_pandyzer/structure/http/models/ApplicationType.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';
import 'package:flutter_pandyzer/structure/http/models/User.dart';
import 'package:flutter_pandyzer/structure/http/services/avaliacao_service.dart';
import 'package:flutter_pandyzer/structure/http/services/dominio_service.dart';
import 'package:flutter_pandyzer/structure/http/services/objetivo_service.dart';
import 'package:flutter_pandyzer/structure/http/services/usuario_service.dart';

mixin AvaliacoesRepository {

  //AVALIAÇÃO
  static void createAvaliacao(Evaluation avaliacao) async {
    return await AvaliacaoService.postAvaliacao(avaliacao);
  }

  static Future<List<Evaluation>> getAvaliacoes() async {
    return await AvaliacaoService.getAvaliacoes();
  }

  static Future<Evaluation> getAvaliacoesById(int id) async {
    return await AvaliacaoService.getAvaliacaoById(id);
  }

  static void putAvaliacao(Evaluation avaliacao) async {
    return await AvaliacaoService.putAvaliacao(avaliacao);
  }

  static void deleteAvaliacao(int id) async {
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
  static void createObjetivo(Objective objetivo) async {
    return await ObjetivoService.postObjetivo(objetivo);
  }

  //USUARIO
  static Future<User> getUsuarioById(int id) async {
    return await UsuarioService.getUsuarioById(id);
  }

}
