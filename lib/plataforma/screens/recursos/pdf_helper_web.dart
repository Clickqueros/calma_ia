// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

String _url(String filename) =>
    'assets/assets/recursos/${Uri.encodeComponent(filename)}';

/// Abre el PDF en una nueva pestaña usando un <a target="_blank">,
/// que el navegador no bloquea como pop-up (a diferencia de window.open).
void abrirPDF(String filename) {
  final anchor = html.AnchorElement(href: _url(filename))
    ..target = '_blank'
    ..rel = 'noopener noreferrer'
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}

/// Fuerza la descarga del PDF.
void descargarPDF(String filename) {
  final anchor = html.AnchorElement(href: _url(filename))
    ..setAttribute('download', filename)
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}
