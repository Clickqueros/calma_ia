// ─────────────────────────────────────────────────────────────────────────────
// CONFIGURACIÓN DE SUPABASE
//
// Pega aquí las 2 credenciales de tu proyecto Supabase:
//   1. Entra a supabase.com → tu proyecto → Settings → API
//   2. Copia "Project URL" y pégalo en supabaseUrl
//   3. Copia "anon public" key y pégalo en supabaseAnonKey
//
// Mientras estén vacías, la app funciona en MODO DEMO (datos de ejemplo).
// En cuanto las pegues, se activa el backend real.
// ─────────────────────────────────────────────────────────────────────────────

class SupabaseConfig {
  SupabaseConfig._();

  static const String supabaseUrl = ''; // ej: https://xxxxx.supabase.co
  static const String supabaseAnonKey = ''; // ej: eyJhbGciOi...

  /// true cuando las credenciales están puestas → backend activo.
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
