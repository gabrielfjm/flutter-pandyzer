import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';
import 'package:flutter_pandyzer/structure/http/services/avaliacoes_service.dart';

mixin AvaliacoesRepository {

  static void createAvaliacao(Evaluation avaliacao) async {
    return AvaliacoesService.postAvaliacao(avaliacao);
  }

  static Future<List<Evaluation>> getAvaliacoes() async {
    return AvaliacoesService.getAvaliacoes();
  }

  static Future<Evaluation> getAvaliacoesById(int id) async {
    return AvaliacoesService.getAvaliacaoById(id);
  }

  static void putAvaliacao(Evaluation avaliacao) async {
    return AvaliacoesService.putAvaliacao(avaliacao);
  }

  static void deleteAvaliacao(int id) async {
    return AvaliacoesService.deleteAvaliacao(id);
  }
}
