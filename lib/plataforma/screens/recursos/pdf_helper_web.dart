// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

void abrirPDF(String filename) {
  final url = 'assets/recursos/${Uri.encodeComponent(filename)}';
  html.window.open(url, '_blank');
}

void descargarPDF(String filename) {
  final url = 'assets/recursos/${Uri.encodeComponent(filename)}';
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}
