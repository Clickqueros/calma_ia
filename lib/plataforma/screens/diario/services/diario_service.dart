import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/nota_model.dart';
import '../../../../core/supabase/supabase_config.dart';
import '../../../../core/auth/auth_service.dart';
import 'storage_stub.dart' if (dart.library.html) 'storage_web.dart';

// ── Service ──────────────────────────────────────────────────────────────────
//
// Si hay sesión Supabase → guarda en la nube (real, persiste entre dispositivos).
// Si no → localStorage del navegador (modo demo).
//
// La interfaz pública (notas / agregar / eliminar) no cambió, así que la
// pantalla del diario sigue funcionando igual.

class DiarioService extends ChangeNotifier {
  DiarioService._() {
    AuthService.instance.addListener(_onAuthChange);
    recargar();
  }

  static final instance = DiarioService._();

  static const _storageKey = 'calma_ia_diario_v1';
  static const _tabla = 'journal_entries';

  final List<NotaDiario> _notas = [];
  List<NotaDiario> get notas => List.unmodifiable(_notas);

  SupabaseClient? get _sb =>
      SupabaseConfig.isConfigured ? Supabase.instance.client : null;
  bool get _haySesion => AuthService.instance.haySesion;

  void _onAuthChange() => recargar();

  // ── Carga ────────────────────────────────────────────────────────────────
  Future<void> recargar() async {
    if (_haySesion && _sb != null) {
      await _cargarDesdeSupabase();
    } else {
      _cargarDesdeLocal();
    }
    notifyListeners();
  }

  Future<void> _cargarDesdeSupabase() async {
    try {
      final uid = AuthService.instance.usuarioActual!.id;
      final rows = await _sb!
          .from(_tabla)
          .select()
          .eq('user_id', uid)
          .order('fecha', ascending: false);
      _notas
        ..clear()
        ..addAll((rows as List).map((r) => NotaDiario(
              id: r['id'].toString(),
              titulo: r['titulo'] ?? '',
              contenido: r['contenido'] ?? '',
              estado: EstadoEmocional.values.firstWhere(
                (e) => e.name == r['estado'],
                orElse: () => EstadoEmocional.tranquilo,
              ),
              fecha: DateTime.tryParse(r['fecha'] ?? '') ?? DateTime.now(),
            )));
    } catch (_) {
      // Si falla la red, no rompemos la UI.
    }
  }

  void _cargarDesdeLocal() {
    _notas.clear();
    try {
      final raw = leerStorage(_storageKey);
      if (raw == null || raw.isEmpty) return;
      final list = jsonDecode(raw) as List<dynamic>;
      _notas.addAll(
        list.map((j) => NotaDiario.fromJson(j as Map<String, dynamic>)),
      );
    } catch (_) {}
  }

  // ── Escritura ──────────────────────────────────────────────────────────────
  Future<void> agregar(NotaDiario nota) async {
    // Optimista: muestra ya en la UI.
    _notas.insert(0, nota);
    notifyListeners();

    if (_haySesion && _sb != null) {
      try {
        final uid = AuthService.instance.usuarioActual!.id;
        await _sb!.from(_tabla).insert({
          'user_id': uid,
          'titulo': nota.titulo,
          'contenido': nota.contenido,
          'estado': nota.estado.name,
          'fecha': nota.fecha.toIso8601String(),
        });
        await _cargarDesdeSupabase(); // refresca con el id real
        notifyListeners();
      } catch (_) {}
    } else {
      _guardarLocal();
    }
  }

  Future<void> eliminar(String id) async {
    _notas.removeWhere((n) => n.id == id);
    notifyListeners();

    if (_haySesion && _sb != null) {
      try {
        await _sb!.from(_tabla).delete().eq('id', id);
      } catch (_) {}
    } else {
      _guardarLocal();
    }
  }

  void _guardarLocal() {
    try {
      final json = jsonEncode(_notas.map((n) => n.toJson()).toList());
      escribirStorage(_storageKey, json);
    } catch (_) {}
  }
}
