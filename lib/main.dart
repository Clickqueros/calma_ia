import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/supabase/supabase_config.dart';
import 'screens/landing_page.dart';
import 'superadmin/superadmin_gate.dart';
import 'admin/real/psicologo_portal.dart';
import 'core/auth/paciente_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // URLs limpias en web: /zeus en vez de /#/zeus
  usePathUrlStrategy();

  // Inicializa Supabase SOLO si hay credenciales.
  // Sin credenciales → la app sigue en modo demo, sin romperse.
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      publishableKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  runApp(const CalmaApp());
}

class CalmaApp extends StatelessWidget {
  const CalmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calma IA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B4EFF)),
        useMaterial3: true,
      ),
      // Rutas por URL:
      //   /            → landing
      //   /zeus        → panel de administración (login admin)
      //   /psicologos  → portal del psicólogo (login)
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final name = (settings.name ?? '/').toLowerCase();
        Widget destino;
        switch (name) {
          case '/zeus':
            destino = const SuperAdminGate();
            break;
          case '/psicologos':
          case '/psicologo':
            destino = const PsicologoPortal();
            break;
          case '/usuario':
          case '/paciente':
          case '/app':
            destino = const PacienteGate();
            break;
          default:
            destino = const LandingPage();
        }
        return MaterialPageRoute(builder: (_) => destino, settings: settings);
      },
    );
  }
}
