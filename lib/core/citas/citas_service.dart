import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_config.dart';
import '../auth/auth_service.dart';

/// ¿El slot (día + hora tipo "8:00 AM") ya pasó respecto a ahora?
bool horaYaPaso(DateTime dia, String hora) {
  final dt = slotDateTime(dia, hora);
  return dt != null && dt.isBefore(DateTime.now());
}

/// Convierte un día + hora ("8:00 AM" / "2:00 PM") a DateTime.
DateTime? slotDateTime(DateTime dia, String hora) {
  final parts = hora.trim().split(' ');
  if (parts.length != 2) return null;
  final hm = parts[0].split(':');
  if (hm.length != 2) return null;
  var h = int.tryParse(hm[0]) ?? 0;
  final m = int.tryParse(hm[1]) ?? 0;
  final pm = parts[1].toUpperCase() == 'PM';
  if (pm && h != 12) h += 12;
  if (!pm && h == 12) h = 0;
  return DateTime(dia.year, dia.month, dia.day, h, m);
}

class CitaReal {
  final String id;
  final String pacienteId;
  final String pacienteNombre;
  final String psicologoId;
  final DateTime fecha;
  final String hora;
  final String modalidad;
  final String motivo;
  final String estado; // agendada | confirmada | cancelada | completada

  const CitaReal({
    required this.id,
    required this.pacienteId,
    required this.pacienteNombre,
    required this.psicologoId,
    required this.fecha,
    required this.hora,
    required this.modalidad,
    required this.motivo,
    required this.estado,
  });

  factory CitaReal.fromRow(Map<String, dynamic> r) => CitaReal(
        id: r['id'].toString(),
        pacienteId: r['paciente_id'].toString(),
        pacienteNombre: r['paciente_nombre'] ?? '',
        psicologoId: r['psicologo_id'].toString(),
        fecha: DateTime.tryParse(r['fecha'] ?? '') ?? DateTime.now(),
        hora: r['hora'] ?? '',
        modalidad: r['modalidad'] ?? 'Videollamada',
        motivo: r['motivo'] ?? '',
        estado: r['estado'] ?? 'agendada',
      );
}

/// Gestiona las citas reales en Supabase.
class CitasService {
  CitasService._();
  static final instance = CitasService._();

  SupabaseClient? get _sb =>
      SupabaseConfig.isConfigured ? Supabase.instance.client : null;
  String? get _uid => AuthService.instance.usuarioActual?.id;

  // ── Paciente: agendar ──────────────────────────────────────────────────────
  Future<String?> agendar({
    required String psicologoId,
    required String pacienteNombre,
    required DateTime fecha,
    required String hora,
    required String modalidad,
    required String motivo,
  }) async {
    if (_sb == null || _uid == null) return 'No hay sesión.';
    try {
      await _sb!.from('appointments').insert({
        'paciente_id': _uid,
        'paciente_nombre': pacienteNombre,
        'psicologo_id': psicologoId,
        'fecha':
            '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}',
        'hora': hora,
        'modalidad': modalidad,
        'motivo': motivo,
        'estado': 'agendada',
      });
      return null;
    } catch (e) {
      return 'Error al agendar: $e';
    }
  }

  // ── Paciente: mis citas ────────────────────────────────────────────────────
  Future<List<CitaReal>> misCitasPaciente() async {
    if (_sb == null || _uid == null) return [];
    try {
      final rows = await _sb!
          .from('appointments')
          .select()
          .eq('paciente_id', _uid!)
          .order('fecha', ascending: true);
      return (rows as List).map((r) => CitaReal.fromRow(r)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Psicólogo: citas de sus pacientes ──────────────────────────────────────
  Future<List<CitaReal>> misCitasPsicologo() async {
    if (_sb == null || _uid == null) return [];
    try {
      final rows = await _sb!
          .from('appointments')
          .select()
          .eq('psicologo_id', _uid!)
          .order('fecha', ascending: true);
      return (rows as List).map((r) => CitaReal.fromRow(r)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Cambiar estado (confirmar/cancelar/completar) ───────────────────────────
  Future<String?> cambiarEstado(String citaId, String estado) async {
    if (_sb == null) return 'Backend no configurado.';
    try {
      await _sb!.from('appointments').update({'estado': estado}).eq('id', citaId);
      return null;
    } catch (e) {
      return 'Error: $e';
    }
  }
}
