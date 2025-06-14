import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:universal_html/html.dart' as html;

class FileDownloaderService {

  static Future<void> downloadAssetPdf({
    required String assetPath,
    required String downloadFileName,
  }) async {
    // Carrega os bytes do arquivo PDF dos assets do projeto
    final ByteData byteData = await rootBundle.load(assetPath);
    final List<int> bytes = byteData.buffer.asUint8List();

    if (kIsWeb) {
      // Lógica para a Web: cria um link de download no navegador
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", downloadFileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Lógica para Mobile (ex: usando um pacote como 'share_plus' para compartilhar)
      // Esta parte requer pacotes adicionais como 'path_provider' e 'share_plus'
      // Exemplo (requer implementação adicional):
      // final tempDir = await getTemporaryDirectory();
      // final file = await File('${tempDir.path}/$downloadFileName').writeAsBytes(bytes);
      // await Share.shareXFiles([XFile(file.path)]);
      print("Funcionalidade de download/compartilhamento para mobile não implementada.");
    }
  }
}