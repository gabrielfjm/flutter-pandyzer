import 'dart:html' as html;
import 'dart:typed_data';

void downloadBytesWeb(Uint8List bytes, String filename, {String mime = 'application/pdf'}) {
  final blob = html.Blob([bytes], mime);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}