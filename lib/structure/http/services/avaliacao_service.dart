import 'dart:convert';
import 'package:flutter_pandyzer/core/http_client.dart';
import 'package:flutter_pandyzer/structure/http/models/Evaluation.dart';

mixin AvaliacaoService {
  static const String _base = '/evaluations';

  // Helper para montar a query string
  static String _qs(Map<String, String> qp) {
    if (qp.isEmpty) return '';
    return '?${Uri(queryParameters: qp).query}';
  }

  static Future<List<Evaluation>> getByCreator(int userId) async {
    final res = await HttpClient.get('$_base/creator/$userId');
    if (res.statusCode != 200) {
      throw Exception('Falha ao buscar avaliações do criador: ${res.statusCode}');
    }
    final List data = jsonDecode(res.body);
    return data.map((e) => Evaluation.fromJson(e)).toList();
  }

  static Future<List<Evaluation>> getCommunityEvaluations(int userId) async {
    final res = await HttpClient.get('$_base/community/$userId');
    if (res.statusCode != 200) {
      throw Exception('Falha ao buscar avaliações da comunidade: ${res.statusCode}');
    }
    final List data = jsonDecode(res.body);
    return data.map((e) => Evaluation.fromJson(e)).toList();
  }

  static Future<List<Evaluation>> filter({
    String? description,
    int? statusId,
    int? creatorId,
  }) async {
    final qp = <String, String>{};
    if (description != null && description.isNotEmpty) qp['description'] = description;
    if (statusId != null) qp['statusId'] = '$statusId';
    if (creatorId != null) qp['creatorId'] = '$creatorId';

    final url = '$_base/filter${_qs(qp)}';
    final res = await HttpClient.get(url);

    if (res.statusCode != 200) {
      throw Exception('Falha no filtro de avaliações: ${res.statusCode}');
    }
    final List data = jsonDecode(res.body);
    return data.map((e) => Evaluation.fromJson(e)).toList();
  }


  static Future<Evaluation> getById(int id) async {
    final res = await HttpClient.get('$_base/$id');
    if (res.statusCode != 200) {
      throw Exception('Falha ao buscar avaliação: ${res.statusCode}');
    }
    return Evaluation.fromJson(jsonDecode(res.body));
  }

  static Future<Evaluation> insert(Evaluation e) async {
    final res = await HttpClient.post(_base, body: e.toJson());
    if (res.statusCode != 201) {
      throw Exception('Falha ao criar avaliação: ${res.statusCode}');
    }
    return Evaluation.fromJson(jsonDecode(res.body));
  }

  static Future<Evaluation> update(int id, Evaluation e) async {
    final res = await HttpClient.put('$_base/$id', body: e.toJson());
    if (res.statusCode != 200) {
      throw Exception('Falha ao atualizar avaliação: ${res.statusCode}');
    }
    return Evaluation.fromJson(jsonDecode(res.body));
  }

  static Future<void> delete(int id) async {
    final res = await HttpClient.delete('$_base/$id');
    if (res.statusCode != 204) {
      throw Exception('Falha ao excluir avaliação: ${res.statusCode}');
    }
  }

  // avaliacao_service.dart
  static Future<List<Evaluation>> getByEvaluator(int userId) async {
    final res = await HttpClient.get('$_base/by-evaluator/$userId');
    if (res.statusCode != 200) {
      throw Exception('Falha ao buscar avaliações onde sou avaliador: ${res.statusCode}');
    }
    final List data = jsonDecode(res.body);
    return data.map((e) => Evaluation.fromJson(e)).toList();
  }

}
