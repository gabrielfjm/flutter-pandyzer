// structure/pages/avaliacoes/avaliacoes_report_service.dart
import 'dart:typed_data';
import 'package:flutter_pandyzer/core/http_client.dart'; // use seu client
import 'package:http/http.dart' as http;

import '../../../core/download_web.dart';

class AvaliacoesReportService {
  static Future<void> downloadConsolidated(int evaluationId) async {
    // se seu HttpClient já possui baseUrl, mantenha o padrão:
    final uri = Uri.parse('${HttpClient.baseUrl}/evaluations/$evaluationId/report');
    final resp = await http.get(uri, headers: await HttpClient.defaultHeaders);

    if (resp.statusCode == 200) {
      downloadBytesWeb(resp.bodyBytes, 'relatorio-avaliacao-$evaluationId.pdf');
    } else {
      final msg = resp.body.isNotEmpty ? resp.body : 'Falha ao baixar relatório (${resp.statusCode}).';
      throw Exception(msg);
    }
  }
}
