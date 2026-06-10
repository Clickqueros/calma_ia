import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_config.dart';
import '../auth/auth_service.dart';

// ── Historia clínica (datos del paciente + valoración inicial) ────────────────

class HistoriaClinica {
  final String pacienteId;
  // Datos del paciente
  final String documento;
  final String fechaNacimiento; // texto libre (dd/mm/aaaa)
  final String sexo;
  final String estadoCivil;
  final String ciudad;
  final String direccion;
  final String telefono;
  final String ocupacion;
  final String entidad; // EPS
  final String tipoUsuario; // régimen
  // Clínico
  final String motivoConsulta;
  final String antecedentes;
  final String valoracionInicial;
  final String diagnosticoCodigo;
  final String diagnosticoNombre;
  final String observaciones;

  const HistoriaClinica({
    required this.pacienteId,
    this.documento = '',
    this.fechaNacimiento = '',
    this.sexo = '',
    this.estadoCivil = '',
    this.ciudad = '',
    this.direccion = '',
    this.telefono = '',
    this.ocupacion = '',
    this.entidad = '',
    this.tipoUsuario = '',
    this.motivoConsulta = '',
    this.antecedentes = '',
    this.valoracionInicial = '',
    this.diagnosticoCodigo = '',
    this.diagnosticoNombre = '',
    this.observaciones = '',
  });

  factory HistoriaClinica.fromRow(Map<String, dynamic> r) => HistoriaClinica(
        pacienteId: r['paciente_id'].toString(),
        documento: r['documento'] ?? '',
        fechaNacimiento: r['fecha_nacimiento'] ?? '',
        sexo: r['sexo'] ?? '',
        estadoCivil: r['estado_civil'] ?? '',
        ciudad: r['ciudad'] ?? '',
        direccion: r['direccion'] ?? '',
        telefono: r['telefono'] ?? '',
        ocupacion: r['ocupacion'] ?? '',
        entidad: r['entidad'] ?? '',
        tipoUsuario: r['tipo_usuario'] ?? '',
        motivoConsulta: r['motivo_consulta'] ?? '',
        antecedentes: r['antecedentes'] ?? '',
        valoracionInicial: r['valoracion_inicial'] ?? '',
        diagnosticoCodigo: r['diagnostico_codigo'] ?? '',
        diagnosticoNombre: r['diagnostico_nombre'] ?? '',
        observaciones: r['observaciones'] ?? '',
      );

  Map<String, dynamic> toRow() => {
        'paciente_id': pacienteId,
        'documento': documento,
        'fecha_nacimiento': fechaNacimiento,
        'sexo': sexo,
        'estado_civil': estadoCivil,
        'ciudad': ciudad,
        'direccion': direccion,
        'telefono': telefono,
        'ocupacion': ocupacion,
        'entidad': entidad,
        'tipo_usuario': tipoUsuario,
        'motivo_consulta': motivoConsulta,
        'antecedentes': antecedentes,
        'valoracion_inicial': valoracionInicial,
        'diagnostico_codigo': diagnosticoCodigo,
        'diagnostico_nombre': diagnosticoNombre,
        'observaciones': observaciones,
        'creado_por': AuthService.instance.usuarioActual?.id,
        'actualizado_en': DateTime.now().toUtc().toIso8601String(),
      };
}

// ── Evolución (estructurada estilo RIPS) ──────────────────────────────────────

class Evolucion {
  final String id;
  final String procedimiento;
  final String tipoDiagnostico;
  final String finalidad;
  final String causaExterna;
  final String diagnosticoCodigo;
  final String diagnosticoNombre;
  final String evolucion;
  final String notaAclaratoria;
  final String adjuntoUrl;
  final String psicologoNombre;
  final DateTime fecha;

  const Evolucion({
    required this.id,
    required this.procedimiento,
    required this.tipoDiagnostico,
    required this.finalidad,
    required this.causaExterna,
    required this.diagnosticoCodigo,
    required this.diagnosticoNombre,
    required this.evolucion,
    required this.notaAclaratoria,
    required this.adjuntoUrl,
    required this.psicologoNombre,
    required this.fecha,
  });

  factory Evolucion.fromRow(Map<String, dynamic> r) => Evolucion(
        id: r['id'].toString(),
        procedimiento: r['procedimiento'] ?? '',
        tipoDiagnostico: r['tipo_diagnostico'] ?? '',
        finalidad: r['finalidad'] ?? '',
        causaExterna: r['causa_externa'] ?? '',
        diagnosticoCodigo: r['diagnostico_codigo'] ?? '',
        diagnosticoNombre: r['diagnostico_nombre'] ?? '',
        evolucion: r['evolucion'] ?? '',
        notaAclaratoria: r['nota_aclaratoria'] ?? '',
        adjuntoUrl: r['adjunto_url'] ?? '',
        psicologoNombre: r['psicologo_nombre'] ?? '',
        fecha: (DateTime.tryParse(r['fecha'] ?? '') ?? DateTime.now()).toLocal(),
      );
}

class HistoriaService {
  HistoriaService._();
  static final instance = HistoriaService._();

  SupabaseClient? get _sb =>
      SupabaseConfig.isConfigured ? Supabase.instance.client : null;

  // ── Historia ─────────────────────────────────────────────────────────────────
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
      await _sb!
          .from('clinical_histories')
          .upsert(h.toRow(), onConflict: 'paciente_id');
      return null;
    } catch (e) {
      return 'Error al guardar: $e';
    }
  }

  // ── Evolución ──────────────────────────────────────────────────────────────
  Future<List<Evolucion>> evoluciones(String pacienteId) async {
    if (_sb == null) return [];
    try {
      final rows = await _sb!
          .from('clinical_evolutions')
          .select()
          .eq('paciente_id', pacienteId)
          .order('fecha', ascending: false);
      return (rows as List).map((r) => Evolucion.fromRow(r)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<String?> agregarEvolucion({
    required String pacienteId,
    required String procedimiento,
    required String tipoDiagnostico,
    required String finalidad,
    required String causaExterna,
    required String diagnosticoCodigo,
    required String diagnosticoNombre,
    required String evolucion,
    required String notaAclaratoria,
    String adjuntoUrl = '',
  }) async {
    if (_sb == null) return 'Backend no configurado.';
    try {
      final nombre =
          AuthService.instance.usuarioActual?.email?.split('@').first ?? '';
      await _sb!.from('clinical_evolutions').insert({
        'paciente_id': pacienteId,
        'procedimiento': procedimiento,
        'tipo_diagnostico': tipoDiagnostico,
        'finalidad': finalidad,
        'causa_externa': causaExterna,
        'diagnostico_codigo': diagnosticoCodigo,
        'diagnostico_nombre': diagnosticoNombre,
        'evolucion': evolucion,
        'nota_aclaratoria': notaAclaratoria,
        'adjunto_url': adjuntoUrl,
        'psicologo_nombre': nombre,
        'fecha': DateTime.now().toUtc().toIso8601String(),
      });
      return null;
    } catch (e) {
      return 'Error: $e';
    }
  }

  // ── Subir archivo adjunto a Storage ──────────────────────────────────────────
  /// Devuelve la URL pública del archivo, o null si falla.
  Future<String?> subirAdjunto({
    required String pacienteId,
    required String nombreArchivo,
    required Uint8List bytes,
  }) async {
    if (_sb == null) return null;
    try {
      final ruta =
          '$pacienteId/${DateTime.now().millisecondsSinceEpoch}_$nombreArchivo';
      await _sb!.storage.from('adjuntos').uploadBinary(ruta, bytes,
          fileOptions: const FileOptions(upsert: true));
      return _sb!.storage.from('adjuntos').getPublicUrl(ruta);
    } catch (_) {
      return null;
    }
  }
}
