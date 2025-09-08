// lib/structure/http/services/application_type_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_pandyzer/structure/http/models/ApplicationType.dart';

class ApplicationTypeService {
  static const String baseUrl = "http://localhost:8080/applicationtype";

  /// Lista todos os ApplicationTypes
  /// Backend: GET /applicationtype
  static Future<List<ApplicationType>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => ApplicationType.fromJson(e)).toList();
    } else {
      throw Exception("Erro ao buscar ApplicationTypes: "
          "${response.statusCode} ${response.body}");
    }
  }

  /// Busca ApplicationType por ID
  /// Backend: GET /applicationtype/{id}
  static Future<ApplicationType> getById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));
    if (response.statusCode == 200) {
      return ApplicationType.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Erro ao buscar ApplicationType $id: "
          "${response.statusCode} ${response.body}");
    }
  }

  /// Cria um novo ApplicationType
  /// Backend: POST /applicationtype
  static Future<ApplicationType> create(ApplicationType appType) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(appType.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return ApplicationType.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Erro ao criar ApplicationType: "
          "${response.statusCode} ${response.body}");
    }
  }

  /// Atualiza um ApplicationType existente
  /// Backend: PUT /applicationtype/{id}
  static Future<ApplicationType> update(ApplicationType appType) async {
    if (appType.id == null) {
      throw Exception("ID é obrigatório para atualizar ApplicationType.");
    }
    final response = await http.put(
      Uri.parse("$baseUrl/${appType.id}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(appType.toJson()),
    );
    if (response.statusCode == 200) {
      return ApplicationType.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Erro ao atualizar ApplicationType ${appType.id}: "
          "${response.statusCode} ${response.body}");
    }
  }

  /// Deleta um ApplicationType
  /// Backend: DELETE /applicationtype/{id}
  static Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));
    if (response.statusCode != 204) {
      throw Exception("Erro ao deletar ApplicationType $id: "
          "${response.statusCode} ${response.body}");
    }
  }
}
