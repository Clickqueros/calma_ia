import 'package:flutter/material.dart';
import '../supabase/supabase_config.dart';
import '../../plataforma/theme/plat_theme.dart';
import 'auth_service.dart';
import 'auth_screen.dart';
import 'perfil_service.dart';
import '../../plataforma/screens/bienvenida_screen.dart';
import '../../plataforma/screens/dashboard_screen.dart';

/// Puerta de entrada del paciente.
/// - Sin backend → entra directo (modo demo de respaldo).
/// - Sin sesión → login/registro obligatorio (como paciente).
/// - Con sesión y rol = paciente → flujo normal.
/// - Con sesión pero OTRO rol (admin/psicólogo) → bloquea (no mezcla roles).
class PacienteGate extends StatefulWidget {
  const PacienteGate({super.key});

  @override
  State<PacienteGate> createState() => _PacienteGateState();
}

class _PacienteGateState extends State<PacienteGate> {
  bool _cargando = true;
  String _rol = 'patient';

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
    if (!SupabaseConfig.isConfigured || !AuthService.instance.haySesion) {
      if (mounted) setState(() => _cargando = false);
      return;
    }
    final rol = await PerfilService.instance.miRol();
    if (mounted) setState(() { _rol = rol; _cargando = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (!SupabaseConfig.isConfigured) return const BienvenidaScreen();

    if (_cargando) {
      return const Scaffold(
        backgroundColor: PlatTheme.softBg,
        body: Center(child: CircularProgressIndicator(color: PlatTheme.purple)),
      );
    }

    if (!AuthService.instance.haySesion) {
      return AuthScreen(
        permitirInvitado: false,
        onAutenticado: () { setState(() => _cargando = true); _init(); },
      );
    }

    // Hay sesión pero NO es paciente → no mezclar roles.
    if (_rol != 'patient') {
      return _OtroRol(rol: _rol);
    }

    // Paciente con sesión → directo al dashboard (no a la bienvenida).
    return const DashboardScreen();
  }
}

class _OtroRol extends StatelessWidget {
  final String rol;
  const _OtroRol({required this.rol});

  String get _label => rol == 'superadmin'
      ? 'administrador'
      : rol == 'psychologist'
          ? 'psicólogo'
          : 'otro rol';

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
                const Icon(Icons.swap_horiz_rounded,
                    color: Color(0xFFFBBF24), size: 48),
                const SizedBox(height: 16),
                Text('Estás con una cuenta de $_label',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                    'Para entrar como paciente, cierra esta sesión e inicia con una cuenta de paciente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: PlatTheme.softBlue, fontSize: 14)),
                const SizedBox(height: 22),
                SizedBox(
                  width: 260,
                  child: ElevatedButton(
                    onPressed: () async =>
                        await AuthService.instance.cerrarSesion(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PlatTheme.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Cerrar sesión',
                        style:
                            TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
