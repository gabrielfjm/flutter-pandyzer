// lib/structure/http/services/objetivo_service.dart
import 'dart:convert';

import 'package:flutter_pandyzer/core/http_client.dart';
import 'package:flutter_pandyzer/structure/http/models/Objective.dart';

mixin ObjetivoService {
  static const String rota = '/objectives';

  // ============ LISTAR / BUSCAR ============

  static Future<List<Objective>> getObjetivos() async {
    final resp = await HttpClient.get(rota);
    if (resp.statusCode == 200) {
      final List<dynamic> data = jsonDecode(resp.body);
      return data
          .map<Objective>((e) => Objective.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Erro ao buscar objetivos: ${resp.statusCode} ${resp.body}');
  }


  static Future<Objective> getObjetivoById(int id) async {
    final resp = await HttpClient.get('$rota/$id');
    if (resp.statusCode == 200) {
      return Objective.fromJson(jsonDecode(resp.body));
    }
    throw Exception(
      'Erro ao buscar objetivo $id: ${resp.statusCode} ${resp.body}',
    );
  }

  /// NOVO nome "canônico"
  static Future<List<Objective>> getByEvaluationId(int evaluationId) async {
    final resp = await HttpClient.get('$rota/evaluation/$evaluationId');

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);

      if (data is List) {
        return data
            .map<Objective>((e) => Objective.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data is Map && data['content'] is List) {
        return (data['content'] as List)
            .map<Objective>((e) => Objective.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return const [];
    }

    throw Exception('Falha ao buscar objetivos (${resp.statusCode})');
  }

  /// Alias de compatibilidade com o código legado
  static Future<List<Objective>> getObjetivoByIdAvaliacao(int id) {
    return getByEvaluationId(id);
  }

  // ============ CRIAR / ATUALIZAR / EXCLUIR ============

  /// Retorna o objetivo criado (o backend devolve o JSON do recurso criado)
  static Future<Objective> create(Objective objetivo) async {
    final resp = await HttpClient.post(rota, body: objetivo.toJson());
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return Objective.fromJson(jsonDecode(resp.body));
    }
    throw Exception(
      'Erro ao criar objetivo: ${resp.statusCode} ${resp.body}',
    );
  }

  /// Alias compatível com chamadas antigas
  static Future<Objective> postObjetivo(Objective objetivo) {
    return create(objetivo);
  }

  /// Atualiza e retorna o objetivo atualizado
  static Future<Objective> update(Objective objetivo) async {
    if (objetivo.id == null) {
      throw Exception('ID do objetivo é obrigatório para atualização.');
    }
    final resp =
    await HttpClient.put('$rota/${objetivo.id}', body: objetivo.toJson());
    if (resp.statusCode == 200) {
      return Objective.fromJson(jsonDecode(resp.body));
    }
    throw Exception(
      'Erro ao atualizar objetivo ${objetivo.id}: '
          '${resp.statusCode} ${resp.body}',
    );
  }

  /// Alias compatível com chamadas antigas
  static Future<Objective> putObjetivo(Objective objetivo) {
    return update(objetivo);
  }

  static Future<void> delete(int id) async {
    final resp = await HttpClient.delete('$rota/$id');
    if (resp.statusCode == 204 || resp.statusCode == 200) return;
    throw Exception(
      'Erro ao deletar objetivo $id: ${resp.statusCode} ${resp.body}',
    );
  }

  /// Alias compatível com chamadas antigas
  static Future<void> deleteObjetivo(int id) {
    return delete(id);
  }
}
