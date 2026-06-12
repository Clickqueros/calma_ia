import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_config.dart';
import '../auth/auth_service.dart';

class RegistroAnimo {
  final DateTime fecha;
  final int nivel; // 0-10
  const RegistroAnimo(this.fecha, this.nivel);
}

// ── Reporte semanal de ánimo ──────────────────────────────────────────────────

class DiaAnimo {
  final DateTime fecha;
  final int? nivel; // null si no calificó ese día
  const DiaAnimo(this.fecha, this.nivel);
}

class ReporteAnimo {
  final List<DiaAnimo> dias; // últimos 7 días (orden ascendente)
  final double? promedio; // 0-10
  final int registros;
  const ReporteAnimo(
      {required this.dias, required this.promedio, required this.registros});

  String get etiqueta {
    if (promedio == null) return 'Sin datos';
    if (promedio! >= 7) return 'Buena semana';
    if (promedio! >= 4) return 'Altibajos';
    return 'Semana difícil';
  }
}

/// Calcula el reporte de los últimos 7 días a partir de los registros.
ReporteAnimo calcularReporteAnimo(List<RegistroAnimo> registros) {
  final ahora = DateTime.now();
  final inicio = DateTime(ahora.year, ahora.month, ahora.day)
      .subtract(const Duration(days: 6));

  bool mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  final dias = <DiaAnimo>[];
  final niveles = <int>[];
  for (var i = 0; i < 7; i++) {
    final dia = inicio.add(Duration(days: i));
    final reg = registros.where((r) => mismoDia(r.fecha, dia)).toList();
    if (reg.isEmpty) {
      dias.add(DiaAnimo(dia, null));
    } else {
      dias.add(DiaAnimo(dia, reg.first.nivel));
      niveles.add(reg.first.nivel);
    }
  }
  final promedio = niveles.isEmpty
      ? null
      : niveles.reduce((a, b) => a + b) / niveles.length;
  return ReporteAnimo(
      dias: dias, promedio: promedio, registros: niveles.length);
}

/// Termómetro de ánimo: el paciente califica su día de 0 a 10.
class AnimoService {
  AnimoService._();
  static final instance = AnimoService._();

  SupabaseClient? get _sb =>
      SupabaseConfig.isConfigured ? Supabase.instance.client : null;
  String? get _uid => AuthService.instance.usuarioActual?.id;

  String _hoyStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  /// Nivel registrado hoy (o null si aún no califica).
  Future<int?> nivelDeHoy() async {
    if (_sb == null || _uid == null) return null;
    try {
      final row = await _sb!
          .from('mood_ratings')
          .select('nivel')
          .eq('user_id', _uid!)
          .eq('fecha', _hoyStr())
          .maybeSingle();
      return row?['nivel'] as int?;
    } catch (_) {
      return null;
    }
  }

  /// Guarda (o actualiza) la calificación de hoy.
  Future<String?> guardarHoy(int nivel) async {
    if (_sb == null || _uid == null) return 'No hay sesión.';
    try {
      await _sb!.from('mood_ratings').upsert({
        'user_id': _uid,
        'fecha': _hoyStr(),
        'nivel': nivel,
      }, onConflict: 'user_id,fecha');
      return null;
    } catch (e) {
      return 'Error al guardar: $e';
    }
  }

  /// Historial de los últimos N días (para gráficas / reporte).
  Future<List<RegistroAnimo>> historial(String pacienteId,
      {int dias = 14}) async {
    if (_sb == null) return [];
    try {
      final rows = await _sb!
          .from('mood_ratings')
          .select('fecha, nivel')
          .eq('user_id', pacienteId)
          .order('fecha', ascending: false)
          .limit(dias);
      return (rows as List)
          .map((r) => RegistroAnimo(
                DateTime.tryParse(r['fecha'] ?? '') ?? DateTime.now(),
                (r['nivel'] as int?) ?? 0,
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
