import 'dart:typed_data';

// La implementación de elegirArchivo() depende de la plataforma.
export 'archivo_picker_stub.dart'
    if (dart.library.html) 'archivo_picker_web.dart';

/// Archivo elegido por el usuario.
class ArchivoElegido {
  final String nombre;
  final Uint8List bytes;
  const ArchivoElegido(this.nombre, this.bytes);
}
