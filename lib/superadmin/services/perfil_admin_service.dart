import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_config.dart';
import '../../core/citas/citas_service.dart';

/// Perfil visto desde la administración (datos NO clínicos).
class PerfilAdmin {
  final String id;
  final String nombre;
  final String email;
  final String rol;
  final String? psicologoId;
  final String telefono;
  final String documento;
  final String registroProfesional;
  final String tarjetaUrl;
  final bool activo;
  final String creadoEn;
  final String enfoque;
  final String areas;
  final int precio;
  final String bio;

  const PerfilAdmin({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.psicologoId,
    this.telefono = '',
    this.documento = '',
    this.registroProfesional = '',
    this.tarjetaUrl = '',
    this.activo = true,
    this.creadoEn = '',
    this.enfoque = '',
    this.areas = '',
    this.precio = 0,
    this.bio = '',
  });
}

/// Servicio del SuperAdmin para gestionar usuarios y relaciones administrativas.
/// NO accede a datos clínicos (diario, historia, notas).
class PerfilAdminService {
  PerfilAdminService._();
  static final instance = PerfilAdminService._();

  SupabaseClient? get _sb =>
      SupabaseConfig.isConfigured ? Supabase.instance.client : null;

  Future<List<PerfilAdmin>> listarTodos() async {
    if (_sb == null) return [];
    try {
      final rows = await _sb!.from('profiles').select(
          'id, nombre, email, rol, psicologo_id, telefono, documento, registro_profesional, tarjeta_url, activo, creado_en, enfoque, areas, precio, bio');
      return (rows as List)
          .map((r) => PerfilAdmin(
                id: r['id'].toString(),
                nombre: (r['nombre'] as String?)?.isNotEmpty == true
                    ? r['nombre']
                    : (r['email'] ?? 'Sin nombre'),
                email: r['email'] ?? '',
                rol: r['rol'] ?? 'patient',
                psicologoId: r['psicologo_id']?.toString(),
                telefono: r['telefono'] ?? '',
                documento: r['documento'] ?? '',
                registroProfesional: r['registro_profesional'] ?? '',
                tarjetaUrl: r['tarjeta_url'] ?? '',
                activo: r['activo'] ?? true,
                creadoEn: r['creado_en']?.toString() ?? '',
                enfoque: r['enfoque'] ?? '',
                areas: r['areas'] ?? '',
                precio: (r['precio'] as int?) ?? 0,
                bio: r['bio'] ?? '',
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

  // ── Subir tarjeta profesional a Storage ──────────────────────────────────────
  Future<String?> subirTarjeta(String nombreArchivo, Uint8List bytes) async {
    if (_sb == null) return null;
    try {
      final ruta = 'tarjetas/${DateTime.now().millisecondsSinceEpoch}_$nombreArchivo';
      await _sb!.storage.from('adjuntos').uploadBinary(ruta, bytes,
          fileOptions: const FileOptions(upsert: true));
      return _sb!.storage.from('adjuntos').getPublicUrl(ruta);
    } catch (_) {
      return null;
    }
  }

  // ── Crear psicólogo (vía Edge Function: robusto y seguro) ────────────────────
  Future<String?> crearPsicologo({
    required String nombre,
    required String email,
    required String password,
    String telefono = '',
    String documento = '',
    String registroProfesional = '',
    String tarjetaUrl = '',
    String enfoque = '',
    String areas = '',
    int precio = 0,
    String bio = '',
  }) async {
    if (!SupabaseConfig.isConfigured) return 'Backend no configurado.';
    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    final err = await _invocarAdmin({
      'accion': 'crear',
      'email': email.trim(),
      'password': password,
      'nombre': nombre.trim(),
      'telefono': telefono.trim(),
      'documento': documento.trim(),
      'registro_profesional': registroProfesional.trim(),
      'tarjeta_url': tarjetaUrl,
    });
    if (err != null) return err;
    // Completar los datos de "match" en el perfil recién creado.
    try {
      final row = await _sb!
          .from('profiles')
          .select('id')
          .eq('email', email.trim())
          .maybeSingle();
      if (row != null) {
        await _sb!.from('profiles').update({
          'enfoque': enfoque.trim(),
          'areas': areas.trim(),
          'precio': precio,
          'bio': bio.trim(),
        }).eq('id', row['id']);
      }
    } catch (_) {}
    return null;
  }

  // ── Editar datos (incluye campos de match) ───────────────────────────────────
  Future<String?> actualizarDatos(
    String userId, {
    required String nombre,
    String telefono = '',
    String documento = '',
    String registroProfesional = '',
    String? tarjetaUrl,
    String? enfoque,
    String? areas,
    int? precio,
    String? bio,
  }) async {
    if (_sb == null) return 'Backend no configurado.';
    try {
      final data = <String, dynamic>{
        'nombre': nombre.trim(),
        'telefono': telefono.trim(),
        'documento': documento.trim(),
        'registro_profesional': registroProfesional.trim(),
      };
      if (tarjetaUrl != null) data['tarjeta_url'] = tarjetaUrl;
      if (enfoque != null) data['enfoque'] = enfoque.trim();
      if (areas != null) data['areas'] = areas.trim();
      if (precio != null) data['precio'] = precio;
      if (bio != null) data['bio'] = bio.trim();
      await _sb!.from('profiles').update(data).eq('id', userId);
      return null;
    } catch (e) {
      return 'Error al actualizar: $e';
    }
  }

  // ── Activar / desactivar (no borra la cuenta) ────────────────────────────────
  Future<String?> setActivo(String userId, bool activo) async {
    if (_sb == null) return 'Backend no configurado.';
    try {
      await _sb!.from('profiles').update({'activo': activo}).eq('id', userId);
      return null;
    } catch (e) {
      return 'Error: $e';
    }
  }

  // ── Acciones que requieren la Edge Function (service_role) ───────────────────
  Future<String?> _invocarAdmin(Map<String, dynamic> body) async {
    if (_sb == null) return 'Backend no configurado.';
    try {
      final res = await _sb!.functions.invoke('admin-psicologos', body: body);
      if (res.status != 200) {
        final data = res.data;
        final msg = (data is Map && data['error'] != null)
            ? data['error'].toString()
            : 'Error ${res.status}';
        return msg;
      }
      return null;
    } catch (e) {
      return 'Error: $e (¿desplegaste la Edge Function "admin-psicologos"?)';
    }
  }

  Future<String?> cambiarEmail(String userId, String nuevoEmail) =>
      _invocarAdmin({'accion': 'email', 'userId': userId, 'email': nuevoEmail.trim()});

  Future<String?> cambiarPassword(String userId, String nuevaPassword) {
    if (nuevaPassword.length < 6) {
      return Future.value('La contraseña debe tener al menos 6 caracteres.');
    }
    return _invocarAdmin(
        {'accion': 'password', 'userId': userId, 'password': nuevaPassword});
  }

  Future<String?> eliminar(String userId) =>
      _invocarAdmin({'accion': 'eliminar', 'userId': userId});

  // ── Citas (solo admin) ───────────────────────────────────────────────────────
  Future<List<CitaReal>> listarCitas() async {
    if (_sb == null) return [];
    try {
      final rows = await _sb!
          .from('appointments')
          .select()
          .order('fecha', ascending: false);
      return (rows as List).map((r) => CitaReal.fromRow(r)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<String?> eliminarCita(String id) async {
    if (_sb == null) return 'Backend no configurado.';
    try {
      await _sb!.from('appointments').delete().eq('id', id);
      return null;
    } catch (e) {
      return 'Error al eliminar la cita: $e';
    }
  }

  /// Editar / reagendar una cita (fecha, hora, modalidad, estado, psicólogo).
  Future<String?> actualizarCita(
    String id, {
    DateTime? fecha,
    String? hora,
    String? modalidad,
    String? estado,
    String? psicologoId,
  }) async {
    if (_sb == null) return 'Backend no configurado.';
    try {
      final data = <String, dynamic>{};
      if (fecha != null) {
        data['fecha'] =
            '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
      }
      if (hora != null) data['hora'] = hora;
      if (modalidad != null) data['modalidad'] = modalidad;
      if (estado != null) data['estado'] = estado;
      if (psicologoId != null) data['psicologo_id'] = psicologoId;
      await _sb!.from('appointments').update(data).eq('id', id);
      return null;
    } catch (e) {
      return 'Error al actualizar la cita: $e';
    }
  }

  // ── Asignación paciente ↔ psicólogo ──────────────────────────────────────────
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

  /// Compatibilidad con el código existente.
  Future<String?> registrarPsicologo({
    required String nombre,
    required String email,
    required String password,
  }) =>
      crearPsicologo(nombre: nombre, email: email, password: password);
}
