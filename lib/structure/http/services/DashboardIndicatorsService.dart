import 'dart:convert';

import 'package:flutter_pandyzer/core/http_client.dart';

import 'package:flutter_pandyzer/structure/http/models/DashboardIndicators.dart';
import 'package:shared_preferences/shared_preferences.dart';

mixin DashboardIndicatorsService {

  static String rota = '/indicators';

  static Future<DashboardIndicators> getIndicatorsByUserId() async {
    try {

      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      final response = await HttpClient.get('$rota/$userId');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DashboardIndicators.fromJson(data);
      } else {
        throw Exception('Erro ao buscar indicadores: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar indicadores');
    }
  }
}