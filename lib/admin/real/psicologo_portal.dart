import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import '../../core/supabase/supabase_config.dart';
import '../../core/auth/auth_service.dart';
import '../../core/auth/auth_screen.dart';
import '../../core/auth/perfil_service.dart';
import '../../plataforma/screens/diario/models/nota_model.dart';
import '../admin_shell.dart';
import 'psicologo_citas_screen.dart';

/// Entrada al portal del psicólogo.
/// - Sin backend → panel demo.
/// - Con backend y sin sesión → login (registro como psicólogo).
/// - Con sesión de psicólogo → pantalla REAL con sus pacientes.
class PsicologoPortal extends StatefulWidget {
  const PsicologoPortal({super.key});

  @override
  State<PsicologoPortal> createState() => _PsicologoPortalState();
}

class _PsicologoPortalState extends State<PsicologoPortal> {
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
    if (!SupabaseConfig.isConfigured) {
      setState(() => _cargando = false);
      return;
    }
    if (!AuthService.instance.haySesion) {
      setState(() => _cargando = false);
      return;
    }
    final rol = await PerfilService.instance.miRol();
    if (mounted) {
      setState(() {
        _rol = rol;
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sin backend → demo directo
    if (!SupabaseConfig.isConfigured) return const AdminShell();

    if (_cargando) {
      return const Scaffold(
        backgroundColor: PlatTheme.softBg,
        body: Center(child: CircularProgressIndicator(color: PlatTheme.purple)),
      );
    }

    // Sin sesión → login como psicólogo
    if (!AuthService.instance.haySesion) {
      return _LoginPsicologo(onListo: () {
        setState(() => _cargando = true);
        _init();
      });
    }

    // Con sesión pero no es psicólogo
    if (_rol != 'psychologist') {
      return _MensajeRol();
    }

    // Psicólogo autenticado → pantalla real
    return const PsicologoRealScreen();
  }
}

// ── Pantalla intermedia de login ──────────────────────────────────────────────

class _LoginPsicologo extends StatelessWidget {
  final VoidCallback onListo;
  const _LoginPsicologo({required this.onListo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlatTheme.softBg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.medical_services_rounded,
                  color: PlatTheme.purple, size: 52),
              const SizedBox(height: 18),
              const Text('Portal Psicólogos',
                  style: TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                  'Inicia sesión o crea tu cuenta profesional para ver a tus pacientes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: PlatTheme.textGray, fontSize: 14)),
              const SizedBox(height: 22),
              SizedBox(
                width: 260,
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            const AuthScreen(rolInicial: 'psychologist')));
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
                  child: const Text('Iniciar sesión / Registrarme',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 260,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminShell())),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PlatTheme.purple,
                    side: const BorderSide(color: Color(0xFFE8E4FF)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ver panel demo',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MensajeRol extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlatTheme.softBg,
      appBar: AppBar(
        backgroundColor: PlatTheme.darkNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Portal Psicólogos',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: PlatTheme.purple, size: 48),
              const SizedBox(height: 16),
              const Text('Esta cuenta no es de psicólogo',
                  style: TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                  'Inicia sesión con una cuenta profesional o regístrate como psicólogo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: PlatTheme.textGray, fontSize: 14)),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  await AuthService.instance.cerrarSesion();
                },
                child: const Text('Cerrar sesión',
                    style: TextStyle(color: PlatTheme.purple)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pantalla REAL: pacientes del psicólogo ───────────────────────────────────

class PsicologoRealScreen extends StatefulWidget {
  const PsicologoRealScreen({super.key});

  @override
  State<PsicologoRealScreen> createState() => _PsicologoRealScreenState();
}

class _PsicologoRealScreenState extends State<PsicologoRealScreen> {
  List<PacienteVinculado> _pacientes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final pacientes = await PerfilService.instance.misPacientes();
    if (mounted) {
      setState(() {
        _pacientes = pacientes;
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = AuthService.instance.usuarioActual?.email ?? '';
    return Scaffold(
      backgroundColor: PlatTheme.softBg,
      appBar: AppBar(
        backgroundColor: PlatTheme.darkNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Mis pacientes',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Mis citas',
            icon: const Icon(Icons.event_note_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const PsicologoCitasScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _cargar,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () async {
              await AuthService.instance.cerrarSesion();
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: PlatTheme.purple))
          : RefreshIndicator(
              onRefresh: _cargar,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _bannerCodigo(email),
                  const SizedBox(height: 20),
                  if (_pacientes.isEmpty)
                    _vacio()
                  else
                    ..._pacientes.map(_pacienteCard),
                ],
              ),
            ),
    );
  }

  Widget _bannerCodigo(String email) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PlatTheme.darkNavy, Color(0xFF2D1B69)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tu código para pacientes',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text(
              'Comparte este correo con tus pacientes. Desde su diario pueden '
              'conectarse contigo y verás su evolución emocional aquí.',
              style: TextStyle(color: PlatTheme.softBlue, fontSize: 12.5, height: 1.4)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.alternate_email_rounded,
                    color: PlatTheme.softPurple, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(email,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vacio() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.people_outline_rounded,
              size: 52, color: PlatTheme.textGray.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('Aún no tienes pacientes vinculados',
              style: TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text(
              'Comparte tu correo (arriba) con un paciente para que se conecte desde su diario.',
              textAlign: TextAlign.center,
              style: TextStyle(color: PlatTheme.textGray, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _pacienteCard(PacienteVinculado p) {
    final iniciales = p.nombre.trim().isEmpty
        ? '?'
        : p.nombre.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase();
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => _DiarioPacienteScreen(paciente: p))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEFECFF)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, gradient: PlatTheme.purpleGradient),
              child: Center(
                child: Text(iniciales,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.nombre,
                      style: const TextStyle(
                          color: PlatTheme.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(p.email,
                      style: const TextStyle(
                          color: PlatTheme.textGray, fontSize: 12.5)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: PlatTheme.textGray),
          ],
        ),
      ),
    );
  }
}

// ── Diario del paciente (solo lectura para el psicólogo) ─────────────────────

class _DiarioPacienteScreen extends StatefulWidget {
  final PacienteVinculado paciente;
  const _DiarioPacienteScreen({required this.paciente});

  @override
  State<_DiarioPacienteScreen> createState() => _DiarioPacienteScreenState();
}

class _DiarioPacienteScreenState extends State<_DiarioPacienteScreen> {
  List<NotaDiario> _notas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final notas =
        await PerfilService.instance.notasDePaciente(widget.paciente.id);
    if (mounted) {
      setState(() {
        _notas = notas;
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlatTheme.softBg,
      appBar: AppBar(
        backgroundColor: PlatTheme.darkNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.paciente.nombre,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: PlatTheme.purple))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EEFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.menu_book_rounded,
                          color: PlatTheme.purple, size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                            'Diario emocional del paciente (solo lectura). El paciente autorizó compartirlo al conectarse contigo.',
                            style: TextStyle(
                                color: Color(0xFF4C1D95),
                                fontSize: 12, height: 1.4)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (_notas.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 50),
                    child: Center(
                      child: Text('Este paciente aún no tiene notas.',
                          style:
                              TextStyle(color: PlatTheme.textGray, fontSize: 14)),
                    ),
                  )
                else
                  ..._notas.map(_notaCard),
              ],
            ),
    );
  }

  Widget _notaCard(NotaDiario n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFECFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: n.estado.bgSuave,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(n.estado.emoji, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 5),
                    Text(n.estado.label,
                        style: TextStyle(
                            color: n.estado.color,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Spacer(),
              Text('${formatearFecha(n.fecha)} · ${formatearHora(n.fecha)}',
                  style:
                      const TextStyle(color: PlatTheme.textGray, fontSize: 11.5)),
            ],
          ),
          if (n.titulo.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(n.titulo,
                style: const TextStyle(
                    color: PlatTheme.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ],
          if (n.contenido.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(n.contenido,
                style: const TextStyle(
                    color: PlatTheme.textGray, fontSize: 13.5, height: 1.5)),
          ],
        ],
      ),
    );
  }
}
