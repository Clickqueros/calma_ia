// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

String? leerStorage(String clave) => html.window.localStorage[clave];

void escribirStorage(String clave, String valor) =>
    html.window.localStorage[clave] = valor;
