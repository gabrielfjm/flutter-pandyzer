import 'dart:typed_data';
import 'package:flutter_pandyzer/core/http_client.dart';

class HttpBytes {
  static Future<Uint8List> getBytes(String url) async {
    final response = await HttpClient.getRaw(url);
    return response.bodyBytes;
  }
}