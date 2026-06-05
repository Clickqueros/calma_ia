import 'package:flutter/material.dart';
import '../plataforma/theme/plat_theme.dart';
import '../core/supabase/supabase_config.dart';
import '../core/auth/auth_service.dart';
import '../core/auth/auth_screen.dart';
import '../core/auth/perfil_service.dart';
import 'superadmin_shell.dart';

/// Puerta de entrada del panel SuperAdmin.
/// Requiere iniciar sesión con una cuenta cuyo rol sea 'superadmin'.
class SuperAdminGate extends StatefulWidget {
  const SuperAdminGate({super.key});

  @override
  State<SuperAdminGate> createState() => _SuperAdminGateState();
}

class _SuperAdminGateState extends State<SuperAdminGate> {
  bool _cargando = true;
  String _rol = '';

  @override
  void initState() {
    super.initState();
    _init();
    AuthService.instance.addListener(_init);
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_init);
    super.dispose();
  }

  Future<void> _init() async {
    if (!SupabaseConfig.isConfigured) {
      if (mounted) setState(() => _cargando = false);
      return;
    }
    if (!AuthService.instance.haySesion) {
      if (mounted) setState(() { _cargando = false; _rol = ''; });
      return;
    }
    setState(() => _cargando = true);
    final rol = await PerfilService.instance.miRol();
    if (mounted) setState(() { _rol = rol; _cargando = false; });
  }

  @override
  Widget build(BuildContext context) {
    // Sin backend → panel demo
    if (!SupabaseConfig.isConfigured) return const SuperAdminShell();

    if (_cargando) {
      return const Scaffold(
        backgroundColor: PlatTheme.darkNavy,
        body: Center(child: CircularProgressIndicator(color: PlatTheme.softPurple)),
      );
    }

    if (!AuthService.instance.haySesion) {
      return _PromptLogin(onListo: () { setState(() => _cargando = true); _init(); });
    }

    if (_rol != 'superadmin') {
      return _NoAdmin();
    }

    return const SuperAdminShell();
  }
}

// ── Pantalla de acceso ────────────────────────────────────────────────────────

class _PromptLogin extends StatelessWidget {
  final VoidCallback onListo;
  const _PromptLogin({required this.onListo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlatTheme.darkNavy,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PlatTheme.purple.withValues(alpha: 0.15),
                    border: Border.all(
                        color: PlatTheme.purple.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded,
                      color: PlatTheme.softPurple, size: 38),
                ),
                const SizedBox(height: 22),
                const Text('Panel de Administración',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                    'Acceso exclusivo para administradores de la plataforma.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: PlatTheme.softBlue, fontSize: 14)),
                const SizedBox(height: 26),
                SizedBox(
                  width: 260,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              const AuthScreen(permitirInvitado: false)));
                      onListo();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PlatTheme.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Iniciar sesión',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Volver',
                      style: TextStyle(color: PlatTheme.softBlue, fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlatTheme.darkNavy,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.block_rounded,
                    color: Color(0xFFFBBF24), size: 48),
                const SizedBox(height: 16),
                const Text('Acceso no autorizado',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                    'Esta cuenta no tiene permisos de administrador.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: PlatTheme.softBlue, fontSize: 14)),
                const SizedBox(height: 22),
                TextButton(
                  onPressed: () async =>
                      await AuthService.instance.cerrarSesion(),
                  child: const Text('Cerrar sesión',
                      style: TextStyle(color: PlatTheme.softPurple)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Volver',
                      style: TextStyle(color: PlatTheme.softBlue, fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
