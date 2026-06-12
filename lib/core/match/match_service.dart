import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_config.dart';
import '../auth/auth_service.dart';

/// Psicólogo con su puntaje de compatibilidad (match).
class PsicologoMatch {
  final String id;
  final String nombre;
  final String email;
  final String avatarUrl;
  final String enfoque;
  final List<String> areas;
  final int precio;
  final String bio;
  final int match; // 0-100

  const PsicologoMatch({
    required this.id,
    required this.nombre,
    required this.email,
    required this.avatarUrl,
    required this.enfoque,
    required this.areas,
    required this.precio,
    required this.bio,
    required this.match,
  });
}

class MatchService {
  MatchService._();
  static final instance = MatchService._();

  SupabaseClient? get _sb =>
      SupabaseConfig.isConfigured ? Supabase.instance.client : null;

  /// Busca psicólogos y los ordena por compatibilidad con las preferencias.
  /// enfoque vacío = "sin preferencia". presupuesto en pesos por sesión.
  Future<List<PsicologoMatch>> buscar({
    required String area,
    required String enfoque,
    required int presupuesto,
  }) async {
    if (_sb == null) return [];
    try {
      final rows = await _sb!
          .from('profiles')
          .select(
              'id, nombre, email, avatar_url, enfoque, areas, precio, bio, activo')
          .eq('rol', 'psychologist');

      final lista = <PsicologoMatch>[];
      for (final r in (rows as List)) {
        if (r['activo'] == false) continue;
        final areas = ((r['areas'] as String?) ?? '')
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        final enf = (r['enfoque'] as String?) ?? '';
        final precio = (r['precio'] as int?) ?? 0;

        // ── Puntaje de compatibilidad ──────────────────────────────────────
        var score = 0;
        // Área (lo más importante)
        if (area.isNotEmpty && areas.contains(area)) {
          score += 55;
        }
        // Enfoque
        if (enfoque.isEmpty || enf == enfoque) {
          score += 25;
        }
        // Presupuesto
        if (precio == 0 || presupuesto == 0 || precio <= presupuesto) {
          score += 20;
        } else {
          // Penaliza según cuánto se pasa
          final exceso = (precio - presupuesto) / presupuesto;
          score += (20 * (1 - exceso).clamp(0, 1)).round();
        }

        lista.add(PsicologoMatch(
          id: r['id'].toString(),
          nombre: (r['nombre'] as String?)?.isNotEmpty == true
              ? r['nombre']
              : (r['email'] ?? 'Psicólogo'),
          email: r['email'] ?? '',
          avatarUrl: r['avatar_url'] ?? '',
          enfoque: enf,
          areas: areas,
          precio: precio,
          bio: r['bio'] ?? '',
          match: score.clamp(0, 100),
        ));
      }
      lista.sort((a, b) => b.match.compareTo(a.match));
      return lista;
    } catch (_) {
      return [];
    }
  }

  /// El paciente elige a su psicólogo (queda asignado).
  Future<String?> elegir(String psicologoId) async {
    if (_sb == null) return 'Backend no configurado.';
    final uid = AuthService.instance.usuarioActual?.id;
    if (uid == null) return 'No hay sesión.';
    try {
      await _sb!
          .from('profiles')
          .update({'psicologo_id': psicologoId}).eq('id', uid);
      return null;
    } catch (e) {
      return 'Error al elegir: $e';
    }
  }
}
