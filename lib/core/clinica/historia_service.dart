import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_config.dart';
import '../auth/auth_service.dart';

class HistoriaClinica {
  final String? id;
  final String pacienteId;
  final String motivoConsulta;
  final String antecedentes;
  final String diagnosticoCodigo;
  final String diagnosticoNombre;
  final String observaciones;

  const HistoriaClinica({
    this.id,
    required this.pacienteId,
    this.motivoConsulta = '',
    this.antecedentes = '',
    this.diagnosticoCodigo = '',
    this.diagnosticoNombre = '',
    this.observaciones = '',
  });

  factory HistoriaClinica.fromRow(Map<String, dynamic> r) => HistoriaClinica(
        id: r['id'].toString(),
        pacienteId: r['paciente_id'].toString(),
        motivoConsulta: r['motivo_consulta'] ?? '',
        antecedentes: r['antecedentes'] ?? '',
        diagnosticoCodigo: r['diagnostico_codigo'] ?? '',
        diagnosticoNombre: r['diagnostico_nombre'] ?? '',
        observaciones: r['observaciones'] ?? '',
      );
}

class Evolucion {
  final String id;
  final String contenido;
  final String psicologoNombre;
  final DateTime fecha;
  const Evolucion(this.id, this.contenido, this.psicologoNombre, this.fecha);
}

/// Gestiona la historia clínica y la evolución por sesión.
class HistoriaService {
  HistoriaService._();
  static final instance = HistoriaService._();

  SupabaseClient? get _sb =>
      SupabaseConfig.isConfigured ? Supabase.instance.client : null;

  // ── Historia clínica ─────────────────────────────────────────────────────────
  Future<HistoriaClinica?> obtener(String pacienteId) async {
    if (_sb == null) return null;
    try {
      final row = await _sb!
          .from('clinical_histories')
          .select()
          .eq('paciente_id', pacienteId)
          .maybeSingle();
      return row == null ? null : HistoriaClinica.fromRow(row);
    } catch (_) {
      return null;
    }
  }

  Future<String?> guardar(HistoriaClinica h) async {
    if (_sb == null) return 'Backend no configurado.';
    try {
      final data = {
        'paciente_id': h.pacienteId,
        'motivo_consulta': h.motivoConsulta,
        'antecedentes': h.antecedentes,
        'diagnostico_codigo': h.diagnosticoCodigo,
        'diagnostico_nombre': h.diagnosticoNombre,
        'observaciones': h.observaciones,
        'creado_por': AuthService.instance.usuarioActual?.id,
        'actualizado_en': DateTime.now().toUtc().toIso8601String(),
      };
      // upsert por paciente_id (una historia por paciente)
      await _sb!.from('clinical_histories').upsert(data, onConflict: 'paciente_id');
      return null;
    } catch (e) {
      return 'Error al guardar: $e';
    }
  }

  // ── Evolución por sesión ──────────────────────────────────────────────────────
  Future<List<Evolucion>> evoluciones(String pacienteId) async {
    if (_sb == null) return [];
    try {
      final rows = await _sb!
          .from('clinical_evolutions')
          .select()
          .eq('paciente_id', pacienteId)
          .order('fecha', ascending: false);
      return (rows as List)
          .map((r) => Evolucion(
                r['id'].toString(),
                r['contenido'] ?? '',
                r['psicologo_nombre'] ?? '',
                (DateTime.tryParse(r['fecha'] ?? '') ?? DateTime.now())
                    .toLocal(),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<String?> agregarEvolucion(String pacienteId, String contenido) async {
    if (_sb == null) return 'Backend no configurado.';
    try {
      final nombre =
          AuthService.instance.usuarioActual?.email?.split('@').first ?? '';
      await _sb!.from('clinical_evolutions').insert({
        'paciente_id': pacienteId,
        'contenido': contenido,
        'psicologo_nombre': nombre,
        'fecha': DateTime.now().toUtc().toIso8601String(),
      });
      return null;
    } catch (e) {
      return 'Error: $e';
    }
  }
}
