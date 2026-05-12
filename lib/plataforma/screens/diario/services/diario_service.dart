import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/nota_model.dart';
import 'storage_stub.dart' if (dart.library.html) 'storage_web.dart';

// ── Service ──────────────────────────────────────────────────────────────────
//
// Stores notes in memory + syncs to browser localStorage on web.
// Ready to be replaced with Supabase: swap _guardar() and _cargar()
// to use an async HTTP/supabase client.

class DiarioService extends ChangeNotifier {
  DiarioService._() {
    _cargar();
  }

  static final instance = DiarioService._();

  static const _storageKey = 'calma_ia_diario_v1';

  final List<NotaDiario> _notas = [];

  List<NotaDiario> get notas => List.unmodifiable(_notas);

  // ── Write ──────────────────────────────────────────────────────────────────

  void agregar(NotaDiario nota) {
    _notas.insert(0, nota);
    _guardar();
    notifyListeners();
  }

  void eliminar(String id) {
    _notas.removeWhere((n) => n.id == id);
    _guardar();
    notifyListeners();
  }

  // ── Persistence ────────────────────────────────────────────────────────────

  void _guardar() {
    try {
      final json = jsonEncode(_notas.map((n) => n.toJson()).toList());
      escribirStorage(_storageKey, json);
    } catch (_) {}
  }

  void _cargar() {
    try {
      final raw = leerStorage(_storageKey);
      if (raw == null || raw.isEmpty) return;
      final list = jsonDecode(raw) as List<dynamic>;
      _notas.addAll(
        list.map((j) => NotaDiario.fromJson(j as Map<String, dynamic>)),
      );
    } catch (_) {}
  }
}
