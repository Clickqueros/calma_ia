// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:url_launcher/url_launcher.dart';

String _url(String filename) =>
    'assets/assets/recursos/${Uri.encodeComponent(filename)}';

/// Abre el PDF en una nueva pestaña. url_launcher maneja correctamente
/// la activación de usuario en Flutter web (a diferencia de window.open
/// o el click programático de un <a>, que el navegador bloquea).
void abrirPDF(String filename) {
  final uri = Uri.base.resolve(_url(filename));
  launchUrl(uri, webOnlyWindowName: '_blank');
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
