import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthService — login, registro y sesión con Supabase.
//
// Si Supabase no está configurado, queda en modo demo (sin sesión real).
// ─────────────────────────────────────────────────────────────────────────────

class AuthService extends ChangeNotifier {
  AuthService._() {
    if (SupabaseConfig.isConfigured) {
      _client = Supabase.instance.client;
      _client!.auth.onAuthStateChange.listen((_) => notifyListeners());
    }
  }
  static final instance = AuthService._();

  SupabaseClient? _client;

  bool get disponible => _client != null;
  User? get usuarioActual => _client?.auth.currentUser;
  bool get haySesion => usuarioActual != null;

  // ── Registro ───────────────────────────────────────────────────────────────
  Future<String?> registrar({
    required String nombre,
    required String email,
    required String password,
    String rol = 'patient', // patient | psychologist
  }) async {
    if (_client == null) return 'Backend no configurado.';
    try {
      await _client!.auth.signUp(
        email: email,
        password: password,
        data: {'nombre': nombre, 'rol': rol},
      );
      return null; // éxito
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  // ── Iniciar sesión ───────────────────────────────────────────────────────────
  Future<String?> iniciarSesion({
    required String email,
    required String password,
  }) async {
    if (_client == null) return 'Backend no configurado.';
    try {
      await _client!.auth.signInWithPassword(email: email, password: password);
      return null; // éxito
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  // ── Cerrar sesión ────────────────────────────────────────────────────────────
  Future<void> cerrarSesion() async {
    await _client?.auth.signOut();
  }
}
