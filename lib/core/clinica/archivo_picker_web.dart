// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data';
import 'archivo_picker.dart';

/// Abre el selector de archivos del navegador (PDF o imagen).
Future<ArchivoElegido?> elegirArchivo() async {
  final input = html.FileUploadInputElement()
    ..accept = '.pdf,image/*'
    ..click();

  await input.onChange.first;
  final files = input.files;
  if (files == null || files.isEmpty) return null;

  final file = files.first;
  final reader = html.FileReader();
  reader.readAsArrayBuffer(file);
  await reader.onLoad.first;

  final bytes = reader.result as Uint8List;
  return ArchivoElegido(file.name, bytes);
}
