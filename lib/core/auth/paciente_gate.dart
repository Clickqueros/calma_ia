import 'package:flutter/material.dart';
import '../supabase/supabase_config.dart';
import 'auth_service.dart';
import 'auth_screen.dart';
import '../../plataforma/screens/bienvenida_screen.dart';

/// Puerta de entrada del paciente.
/// - Sin backend → entra directo (modo demo de respaldo).
/// - Sin sesión → login/registro obligatorio (como paciente).
/// - Con sesión → flujo normal (bienvenida → cuestionario → dashboard).
class PacienteGate extends StatelessWidget {
  const PacienteGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (!SupabaseConfig.isConfigured) return const BienvenidaScreen();

    return AnimatedBuilder(
      animation: AuthService.instance,
      builder: (context, _) {
        if (AuthService.instance.haySesion) {
          return const BienvenidaScreen();
        }
        return AuthScreen(
          permitirInvitado: false,
          onAutenticado: () {/* el AnimatedBuilder reconstruye solo */},
        );
      },
    );
  }
}
