// lib/core/http_client.dart
import 'dart:convert';
import 'dart:typed_data'; // <- para Uint8List
import 'package:http/http.dart' as http;

// Só será usado no Flutter Web; se você compilar para mobile, não chame essa função.
// (No Web é seguro importar 'dart:html')
import 'dart:html' as html show AnchorElement, Blob, Url;

class HttpClient {
  static const String baseUrl = 'http://localhost:8080';

  static Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: defaultHeaders);
  }

  static Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      url,
      headers: defaultHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  static Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.put(
      url,
      headers: defaultHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  static Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.delete(url, headers: defaultHeaders);
  }

  /// ---- Requisição "crua" para bytes (PDF, imagens etc.) ----
  static Future<http.Response> getRaw(
      String endpoint, {
        Map<String, String>? headers,
      }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final merged = <String, String>{
      ...defaultHeaders,
      // Aceita PDF também
      'Accept': 'application/pdf, application/json',
    };
    // Em GET não precisamos de Content-Type
    merged.remove('Content-Type');
    if (headers != null) merged.addAll(headers);
    return await http.get(url, headers: merged);
  }

  /// ---- Baixa bytes no navegador (Flutter Web) ----
  static void downloadBytesWeb(Uint8List bytes, String filename, {String mime = 'application/pdf'}) {
    final blob = html.Blob([bytes], mime);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)..download = filename;
    anchor.click();
    html.Url.revokeObjectUrl(url);
  }
}
