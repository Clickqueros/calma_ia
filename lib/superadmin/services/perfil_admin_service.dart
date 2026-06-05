import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_config.dart';

/// Perfil visto desde la administración (datos NO clínicos).
class PerfilAdmin {
  final String id;
  final String nombre;
  final String email;
  final String rol;
  final String? psicologoId;

  const PerfilAdmin({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.psicologoId,
  });
}

/// Servicio del SuperAdmin para gestionar relaciones administrativas.
/// NO accede a datos clínicos (diario, historia, notas).
class PerfilAdminService {
  PerfilAdminService._();
  static final instance = PerfilAdminService._();

  SupabaseClient? get _sb =>
      SupabaseConfig.isConfigured ? Supabase.instance.client : null;

  Future<List<PerfilAdmin>> listarTodos() async {
    if (_sb == null) return [];
    try {
      final rows = await _sb!
          .from('profiles')
          .select('id, nombre, email, rol, psicologo_id');
      return (rows as List)
          .map((r) => PerfilAdmin(
                id: r['id'].toString(),
                nombre: (r['nombre'] as String?)?.isNotEmpty == true
                    ? r['nombre']
                    : (r['email'] ?? 'Sin nombre'),
                email: r['email'] ?? '',
                rol: r['rol'] ?? 'patient',
                psicologoId: r['psicologo_id']?.toString(),
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<PerfilAdmin>> pacientes() async =>
      (await listarTodos()).where((p) => p.rol == 'patient').toList();

  Future<List<PerfilAdmin>> psicologos() async =>
      (await listarTodos()).where((p) => p.rol == 'psychologist').toList();

  /// Asigna (o reasigna) un paciente a un psicólogo.
  Future<String?> asignar(String pacienteId, String? psicologoId) async {
    if (_sb == null) return 'Backend no configurado.';
    try {
      await _sb!
          .from('profiles')
          .update({'psicologo_id': psicologoId}).eq('id', pacienteId);
      return null;
    } catch (e) {
      return 'Error al asignar: $e';
    }
  }
}
