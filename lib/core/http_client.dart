import 'dart:convert';
import 'package:http/http.dart' as http;

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
}
