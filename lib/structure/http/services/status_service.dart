import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_pandyzer/structure/http/models/Status.dart';

class StatusService {
  static const String baseUrl = "https://panda-microservice-f3d5adc8dxewfub8.brazilsouth-01.azurewebsites.net/status";

  // ===== Nomes padronizados que o repository espera =====
  static Future<List<Status>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => Status.fromJson(e)).toList();
    }
    throw Exception("Erro ao buscar statuses: ${response.statusCode}");
  }

  static Future<Status> getById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));
    if (response.statusCode == 200) {
      return Status.fromJson(jsonDecode(response.body));
    }
    throw Exception("Erro ao buscar status $id: ${response.statusCode}");
  }

  // ===== Aliases (backward compatibility) =====
  static Future<List<Status>> getStatuses() => getAll();
  static Future<Status> getStatusById(int id) => getById(id);
}
