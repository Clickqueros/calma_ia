import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_config.dart';
import 'auth_service.dart';
import '../../plataforma/screens/diario/models/nota_model.dart';

/// Paciente vinculado a un psicólogo (vista del profesional).
class PacienteVinculado {
  final String id;
  final String nombre;
  final String email;
  const PacienteVinculado(
      {required this.id, required this.nombre, required this.email});
}

/// Maneja el perfil del usuario y la relación paciente↔psicólogo.
class PerfilService {
  PerfilService._();
  static final instance = PerfilService._();

  SupabaseClient? get _sb =>
      SupabaseConfig.isConfigured ? Supabase.instance.client : null;
  String? get _uid => AuthService.instance.usuarioActual?.id;

  // ── Mi perfil ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> miPerfil() async {
    if (_sb == null || _uid == null) return null;
    try {
      return await _sb!.from('profiles').select().eq('id', _uid!).maybeSingle();
    } catch (_) {
      return null;
    }
  }

  Future<String> miRol() async {
    final p = await miPerfil();
    return (p?['rol'] as String?) ?? 'patient';
  }

  // ── Foto de perfil (avatar) ──────────────────────────────────────────────────
  /// Sube la foto a Storage y devuelve su URL pública (o null).
  Future<String?> subirAvatar(String nombreArchivo, Uint8List bytes) async {
    if (_sb == null || _uid == null) return null;
    try {
      final ruta = 'avatares/${_uid}_${DateTime.now().millisecondsSinceEpoch}_$nombreArchivo';
      await _sb!.storage.from('adjuntos').uploadBinary(ruta, bytes,
          fileOptions: const FileOptions(upsert: true));
      return _sb!.storage.from('adjuntos').getPublicUrl(ruta);
    } catch (_) {
      return null;
    }
  }

  Future<String?> actualizarAvatar(String url) async {
    if (_sb == null || _uid == null) return 'No hay sesión.';
    try {
      await _sb!.from('profiles').update({'avatar_url': url}).eq('id', _uid!);
      return null;
    } catch (e) {
      return 'Error: $e';
    }
  }

  // ── Vincular paciente con su psicólogo (por correo) ─────────────────────────
  Future<String?> vincularConPsicologo(String emailPsicologo) async {
    if (_sb == null || _uid == null) return 'No hay sesión.';
    try {
      final psico = await _sb!
          .from('profiles')
          .select('id, rol')
          .eq('email', emailPsicologo.trim())
          .eq('rol', 'psychologist')
          .maybeSingle();
      if (psico == null) {
        return 'No se encontró un psicólogo con ese correo.';
      }
      await _sb!
          .from('profiles')
          .update({'psicologo_id': psico['id']}).eq('id', _uid!);
      return null; // éxito
    } catch (e) {
      return 'Error al vincular: $e';
    }
  }

  Future<bool> tengoPsicologo() async {
    final p = await miPerfil();
    return p?['psicologo_id'] != null;
  }

  /// Datos básicos del psicólogo asignado al paciente actual (o null).
  Future<Map<String, dynamic>?> miPsicologo() async {
    if (_sb == null) return null;
    final p = await miPerfil();
    final pid = p?['psicologo_id'];
    if (pid == null) return null;
    try {
      return await _sb!
          .from('profiles')
          .select('nombre, email')
          .eq('id', pid)
          .maybeSingle();
    } catch (_) {
      return null;
    }
  }

  // ── Para el psicólogo: sus pacientes ────────────────────────────────────────
  Future<List<PacienteVinculado>> misPacientes() async {
    if (_sb == null || _uid == null) return [];
    try {
      final rows = await _sb!
          .from('profiles')
          .select('id, nombre, email')
          .eq('psicologo_id', _uid!);
      return (rows as List)
          .map((r) => PacienteVinculado(
                id: r['id'].toString(),
                nombre: (r['nombre'] as String?)?.isNotEmpty == true
                    ? r['nombre']
                    : (r['email'] ?? 'Paciente'),
                email: r['email'] ?? '',
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Última nota del paciente (la más reciente), o null si no tiene.
  Future<NotaDiario?> ultimaNotaDe(String pacienteId) async {
    final notas = await notasDePaciente(pacienteId);
    return notas.isEmpty ? null : notas.first;
  }

  // ── Para el psicólogo: el diario de un paciente (solo lectura) ───────────────
  Future<List<NotaDiario>> notasDePaciente(String pacienteId) async {
    if (_sb == null) return [];
    try {
      final rows = await _sb!
          .from('journal_entries')
          .select()
          .eq('user_id', pacienteId)
          .order('fecha', ascending: false);
      return (rows as List)
          .map((r) => NotaDiario(
                id: r['id'].toString(),
                titulo: r['titulo'] ?? '',
                contenido: r['contenido'] ?? '',
                estado: EstadoEmocional.values.firstWhere(
                  (e) => e.name == r['estado'],
                  orElse: () => EstadoEmocional.tranquilo,
                ),
                fecha: (DateTime.tryParse(r['fecha'] ?? '') ?? DateTime.now())
                    .toLocal(),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
