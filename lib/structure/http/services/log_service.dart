import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/Log.dart';

mixin LogService {

  static String rota = '/logs';

  static Future<List<Log>> getActivityLogs(int userId) async {
    final response = await http.get(Uri.parse('$rota/logs/user/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((logJson) => Log.fromJson(logJson)).toList();
    } else {
      throw Exception('Falha ao carregar os logs de atividade.');
    }
  }

}
