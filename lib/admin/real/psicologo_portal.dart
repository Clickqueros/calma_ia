import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import '../../core/supabase/supabase_config.dart';
import '../../core/auth/auth_service.dart';
import '../../core/auth/auth_screen.dart';
import '../../core/auth/perfil_service.dart';
import '../../core/citas/citas_service.dart';
import '../../core/clinica/archivo_picker.dart';
import '../../plataforma/screens/diario/models/nota_model.dart';
import 'historia_clinica_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Portal del psicólogo. Gate de login + panel real con datos de Supabase.
// ─────────────────────────────────────────────────────────────────────────────

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
    if (!SupabaseConfig.isConfigured || !AuthService.instance.haySesion) {
      if (mounted) setState(() => _cargando = false);
      return;
    }
    final rol = await PerfilService.instance.miRol();
    if (mounted) setState(() { _rol = rol; _cargando = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        backgroundColor: PlatTheme.softBg,
        body: Center(child: CircularProgressIndicator(color: PlatTheme.purple)),
      );
    }
    if (!SupabaseConfig.isConfigured || !AuthService.instance.haySesion) {
      return _LoginPsicologo(onListo: () { setState(() => _cargando = true); _init(); });
    }
    if (_rol != 'psychologist') return _MensajeRol();
    return const PsicologoShell();
  }
}

// ── Login ─────────────────────────────────────────────────────────────────────

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
                  'Inicia sesión con la cuenta que te entregó tu administrador.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: PlatTheme.textGray, fontSize: 14)),
              const SizedBox(height: 24),
              SizedBox(
                width: 260,
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const AuthScreen(
                            permitirInvitado: false, soloLogin: true)));
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
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Volver',
                    style: TextStyle(color: PlatTheme.textGray, fontSize: 13)),
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
              const Text('Inicia sesión con una cuenta profesional.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: PlatTheme.textGray, fontSize: 14)),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () async =>
                    await AuthService.instance.cerrarSesion(),
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

// ── Modelo de resumen ─────────────────────────────────────────────────────────

class _ResumenPaciente {
  final PacienteVinculado p;
  final NotaDiario? ultima;
  final ReporteSemanal reporte;
  const _ResumenPaciente(this.p, this.ultima, this.reporte);
}

// ─────────────────────────────────────────────────────────────────────────────
// PsicologoShell — panel completo con sidebar (desktop) / bottomnav (móvil)
// ─────────────────────────────────────────────────────────────────────────────

class PsicologoShell extends StatefulWidget {
  const PsicologoShell({super.key});

  @override
  State<PsicologoShell> createState() => _PsicologoShellState();
}

class _PsicologoShellState extends State<PsicologoShell> {
  int _selected = 0;
  bool _cargando = true;
  List<_ResumenPaciente> _pacientes = [];
  List<CitaReal> _citas = [];
  String _avatarUrl = '';
  String _nombre = '';
  bool _subiendoAvatar = false;

  static const _nav = [
    (Icons.grid_view_rounded, 'Dashboard'),
    (Icons.event_note_rounded, 'Agenda'),
    (Icons.people_alt_rounded, 'Pacientes'),
  ];

  bool get _small => MediaQuery.of(context).size.width < 900;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final perfil = await PerfilService.instance.miPerfil();
    _avatarUrl = (perfil?['avatar_url'] as String?) ?? '';
    _nombre = (perfil?['nombre'] as String?) ?? '';
    final pacientes = await PerfilService.instance.misPacientes();
    final resumenes = <_ResumenPaciente>[];
    for (final p in pacientes) {
      final notas = await PerfilService.instance.notasDePaciente(p.id);
      resumenes.add(_ResumenPaciente(
          p, notas.isEmpty ? null : notas.first, calcularReporteSemanal(notas)));
    }
    final citas = await CitasService.instance.misCitasPsicologo();
    if (mounted) {
      setState(() {
        _pacientes = resumenes;
        _citas = citas;
        _cargando = false;
      });
    }
  }

  bool _esHoy(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  List<CitaReal> get _citasHoy => _citas
      .where((c) =>
          _esHoy(c.fecha) &&
          (c.estado == 'agendada' || c.estado == 'confirmada'))
      .toList();
  List<CitaReal> get _proximas => _citas
      .where((c) =>
          c.fecha.isAfter(DateTime.now()) &&
          !_esHoy(c.fecha) &&
          (c.estado == 'agendada' || c.estado == 'confirmada'))
      .toList();
  List<_ResumenPaciente> get _alertas => _pacientes
      .where((r) =>
          r.ultima != null &&
          (r.ultima!.estado == EstadoEmocional.ansioso ||
              r.ultima!.estado == EstadoEmocional.triste))
      .toList();

  String get _titulo => _nav[_selected].$2;

  Widget get _contenido {
    if (_cargando) {
      return const Center(
          child: CircularProgressIndicator(color: PlatTheme.purple));
    }
    return switch (_selected) {
      1 => _agendaTab(),
      2 => _pacientesTab(),
      _ => _dashboardTab(),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_small) {
      return Scaffold(
        backgroundColor: PlatTheme.softBg,
        appBar: AppBar(
          backgroundColor: PlatTheme.darkNavy,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white54, size: 18),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(_titulo,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: _cargar,
            ),
          ],
        ),
        body: _contenido,
        bottomNavigationBar: _bottomNav(),
      );
    }
    return Scaffold(
      backgroundColor: PlatTheme.softBg,
      body: Row(
        children: [
          _sidebar(),
          Expanded(child: _contenido),
        ],
      ),
    );
  }

  // ── Sidebar ────────────────────────────────────────────────────────────────
  Widget _sidebar() {
    final email = AuthService.instance.usuarioActual?.email ?? '';
    return Container(
      width: 256,
      color: PlatTheme.darkNavy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 6),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, gradient: PlatTheme.purpleGradient),
                  child: const Icon(Icons.self_improvement,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Text('calma',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(107, 78, 255, 0.25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('PSICÓLOGO',
                  style: TextStyle(
                      color: PlatTheme.softBlue,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2)),
            ),
          ),
          const SizedBox(height: 20),
          _perfilSidebar(),
          const SizedBox(height: 20),
          ..._nav.asMap().entries.map((e) =>
              _sidebarItem(e.key, e.value.$1, e.value.$2)),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Color.fromRGBO(176, 191, 255, 0.5), fontSize: 11)),
          ),
          GestureDetector(
            onTap: () async {
              final nav = Navigator.of(context);
              await AuthService.instance.cerrarSesion();
              nav.maybePop();
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(28, 8, 24, 22),
              child: const Row(
                children: [
                  Icon(Icons.logout_rounded, color: Color(0xFFFF8A8A), size: 20),
                  SizedBox(width: 12),
                  Text('Cerrar sesión',
                      style: TextStyle(
                          color: Color(0xFFFF8A8A),
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Perfil con foto (sidebar) ────────────────────────────────────────────────
  Widget _perfilSidebar() {
    final email = AuthService.instance.usuarioActual?.email ?? '';
    final nombre = _nombre.isNotEmpty ? _nombre : email.split('@').first;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(107, 78, 255, 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color.fromRGBO(107, 78, 255, 0.3)),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: _subiendoAvatar ? null : _cambiarFoto,
              child: _avatarCircle(46),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  GestureDetector(
                    onTap: _subiendoAvatar ? null : _cambiarFoto,
                    child: Text(_subiendoAvatar ? 'Subiendo...' : 'Cambiar foto',
                        style: const TextStyle(
                            color: PlatTheme.softBlue,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarCircle(double size) {
    if (_subiendoAvatar) {
      return SizedBox(
        width: size,
        height: size,
        child: const Center(
            child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))),
      );
    }
    if (_avatarUrl.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1.5),
          image: DecorationImage(
              image: NetworkImage(_avatarUrl), fit: BoxFit.cover),
        ),
      );
    }
    final inicial = (_nombre.isNotEmpty
            ? _nombre
            : (AuthService.instance.usuarioActual?.email ?? '?'))[0]
        .toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
          shape: BoxShape.circle, gradient: PlatTheme.purpleGradient),
      child: Center(
        child: Text(inicial,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.4)),
      ),
    );
  }

  Future<void> _cambiarFoto() async {
    final archivo = await elegirArchivo();
    if (archivo == null) return;
    setState(() => _subiendoAvatar = true);
    try {
      final url = await PerfilService.instance
          .subirAvatar(archivo.nombre, archivo.bytes);
      await PerfilService.instance.actualizarAvatar(url);
      if (!mounted) return;
      setState(() {
        _subiendoAvatar = false;
        _avatarUrl = url;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _subiendoAvatar = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al subir: $e'),
        backgroundColor: const Color(0xFFDC2626),
        duration: const Duration(seconds: 6),
      ));
    }
  }

  Widget _sidebarItem(int i, IconData icon, String label) {
    final sel = _selected == i;
    return GestureDetector(
      onTap: () => setState(() => _selected = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: sel
              ? const Color.fromRGBO(107, 78, 255, 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: sel
                  ? const Color.fromRGBO(107, 78, 255, 0.4)
                  : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: sel
                    ? PlatTheme.softPurple
                    : const Color.fromRGBO(176, 191, 255, 0.55),
                size: 20),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    color: sel
                        ? Colors.white
                        : const Color.fromRGBO(176, 191, 255, 0.65),
                    fontSize: 14,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }

  Widget _bottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: PlatTheme.darkNavy,
        border: Border(top: BorderSide(color: Color(0xFF2D2460))),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _nav.asMap().entries.map((e) {
              final sel = _selected == e.key;
              return GestureDetector(
                onTap: () => setState(() => _selected = e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel
                        ? const Color.fromRGBO(107, 78, 255, 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(e.value.$1,
                          color: sel
                              ? PlatTheme.softPurple
                              : const Color.fromRGBO(176, 191, 255, 0.5),
                          size: 22),
                      const SizedBox(height: 4),
                      Text(e.value.$2,
                          style: TextStyle(
                              color: sel
                                  ? PlatTheme.softPurple
                                  : const Color.fromRGBO(176, 191, 255, 0.5),
                              fontSize: 10,
                              fontWeight:
                                  sel ? FontWeight.w700 : FontWeight.w400)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ── Tab: Dashboard ───────────────────────────────────────────────────────────
  Widget _dashboardTab() {
    final nombre = _nombre.isNotEmpty
        ? _nombre.split(' ').first
        : (AuthService.instance.usuarioActual?.email?.split('@').first ?? '');
    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView(
        padding: EdgeInsets.all(_small ? 18 : 32),
        children: [
          Text('Hola, $nombre 👋',
              style: const TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Resumen de tu consulta.',
              style: TextStyle(color: PlatTheme.textGray, fontSize: 14)),
          const SizedBox(height: 18),
          _stats(),
          const SizedBox(height: 22),
          if (_alertas.isNotEmpty) ...[
            _tituloSeccion('Alertas', Icons.notifications_active_rounded,
                const Color(0xFFDC2626)),
            const SizedBox(height: 10),
            ..._alertas.map(_alertaCard),
            const SizedBox(height: 22),
          ],
          _tituloSeccion('Citas de hoy', Icons.today_rounded, PlatTheme.purple),
          const SizedBox(height: 10),
          if (_citasHoy.isEmpty)
            _cajaVacia('No tienes citas para hoy.')
          else
            ..._citasHoy.map((c) => _citaMini(c)),
          const SizedBox(height: 22),
          _tituloSeccion('Bienestar de tus pacientes',
              Icons.favorite_rounded, PlatTheme.purple),
          const SizedBox(height: 10),
          if (_pacientes.isEmpty)
            _cajaVacia('Aún no tienes pacientes vinculados.')
          else
            ..._pacientes.map((r) => _pacienteCard(r)),
          const SizedBox(height: 22),
          _bannerCodigo(),
        ],
      ),
    );
  }

  Widget _stats() {
    Widget card(IconData ic, Color c, String v, String l) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEFECFF))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(ic, color: c, size: 19),
                ),
                const SizedBox(height: 10),
                Text(v,
                    style: const TextStyle(
                        color: PlatTheme.textDark,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                Text(l,
                    style: const TextStyle(
                        color: PlatTheme.textGray, fontSize: 11.5)),
              ],
            ),
          ),
        );
    return Row(children: [
      card(Icons.people_alt_rounded, PlatTheme.purple, '${_pacientes.length}',
          'Pacientes'),
      const SizedBox(width: 12),
      card(Icons.today_rounded, const Color(0xFF059669), '${_citasHoy.length}',
          'Citas hoy'),
      const SizedBox(width: 12),
      card(Icons.upcoming_rounded, const Color(0xFFD97706),
          '${_proximas.length}', 'Próximas'),
    ]);
  }

  Widget _tituloSeccion(String t, IconData ic, Color c) => Row(
        children: [
          Icon(ic, color: c, size: 19),
          const SizedBox(width: 8),
          Text(t,
              style: const TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      );

  Widget _cajaVacia(String t) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEFECFF))),
        child: Text(t,
            style: const TextStyle(color: PlatTheme.textGray, fontSize: 13)),
      );

  Widget _alertaCard(_ResumenPaciente r) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFCA5A5))),
        child: Row(
          children: [
            Text(r.ultima!.estado.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                  '${r.p.nombre} reportó ${r.ultima!.estado.label.toLowerCase()}',
                  style: const TextStyle(
                      color: Color(0xFF991B1B),
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => _DiarioPacienteScreen(paciente: r.p))),
              child: const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFFDC2626)),
            ),
          ],
        ),
      );

  Widget _bannerCodigo() {
    final email = AuthService.instance.usuarioActual?.email ?? '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [PlatTheme.darkNavy, Color(0xFF2D1B69)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tu correo para vincular pacientes',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
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
                            fontWeight: FontWeight.w600))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab: Agenda ────────────────────────────────────────────────────────────
  Widget _agendaTab() {
    const meses = ['', 'ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago',
      'sep', 'oct', 'nov', 'dic'];
    const dias = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final ordenadas = [..._citas]..sort((a, b) => a.fecha.compareTo(b.fecha));

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView(
        padding: EdgeInsets.all(_small ? 18 : 32),
        children: [
          if (!_small)
            const Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: Text('Agenda',
                  style: TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ),
          if (ordenadas.isEmpty)
            _cajaVacia('No tienes citas. Tus pacientes pueden agendar desde su app.')
          else
            ...ordenadas.map((c) {
              final color = switch (c.estado) {
                'confirmada' => const Color(0xFF059669),
                'cancelada' => const Color(0xFFDC2626),
                'completada' => const Color(0xFF6B7280),
                _ => PlatTheme.purple,
              };
              final label = switch (c.estado) {
                'confirmada' => 'Confirmada',
                'cancelada' => 'Cancelada',
                'completada' => 'Completada',
                _ => 'Agendada',
              };
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEFECFF))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: PlatTheme.purpleGradient),
                          child: Center(
                              child: Text(
                                  c.pacienteNombre.isNotEmpty
                                      ? c.pacienteNombre[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  c.pacienteNombre.isNotEmpty
                                      ? c.pacienteNombre
                                      : 'Paciente',
                                  style: const TextStyle(
                                      color: PlatTheme.textDark,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold)),
                              if (c.motivo.isNotEmpty)
                                Text(c.motivo,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: PlatTheme.textGray,
                                        fontSize: 12)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(label,
                              style: TextStyle(
                                  color: color,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(height: 1, color: const Color(0xFFF2F0FF)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 14, color: PlatTheme.textGray),
                        const SizedBox(width: 6),
                        Text(
                            '${dias[c.fecha.weekday]} ${c.fecha.day} ${meses[c.fecha.month]}',
                            style: const TextStyle(
                                color: PlatTheme.textDark,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 14),
                        Icon(Icons.schedule_rounded,
                            size: 14, color: PlatTheme.textGray),
                        const SizedBox(width: 5),
                        Text(c.hora,
                            style: const TextStyle(
                                color: PlatTheme.textDark,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    if (c.estado == 'agendada' || c.estado == 'confirmada') ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          if (c.estado == 'agendada')
                            Expanded(
                                child: _btnCita('Confirmar',
                                    const Color(0xFF059669), () => _cambiarCita(c, 'confirmada'))),
                          if (c.estado == 'confirmada')
                            Expanded(
                                child: _btnCita('Completar',
                                    const Color(0xFF6B7280), () => _cambiarCita(c, 'completada'))),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _btnCita('Cancelar',
                                  const Color(0xFFDC2626), () => _cambiarCita(c, 'cancelada'),
                                  outline: true)),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _cambiarCita(CitaReal c, String estado) async {
    await CitasService.instance.cambiarEstado(c.id, estado);
    _cargar();
  }

  Widget _btnCita(String label, Color color, VoidCallback onTap,
      {bool outline = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: outline ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: color)),
        child: Text(label,
            style: TextStyle(
                color: outline ? color : Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  // ── Tab: Pacientes ───────────────────────────────────────────────────────────
  Widget _pacientesTab() {
    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView(
        padding: EdgeInsets.all(_small ? 18 : 32),
        children: [
          if (!_small)
            const Padding(
              padding: EdgeInsets.only(bottom: 18),
              child: Text('Pacientes',
                  style: TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ),
          if (_pacientes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.people_outline_rounded,
                      size: 52,
                      color: PlatTheme.textGray.withValues(alpha: 0.4)),
                  const SizedBox(height: 14),
                  const Text('Aún no tienes pacientes vinculados',
                      style: TextStyle(
                          color: PlatTheme.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text(
                      'Comparte tu correo con un paciente o pide al admin que te asigne.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: PlatTheme.textGray, fontSize: 13)),
                ],
              ),
            )
          else
            ..._pacientes.map((r) => _pacienteCard(r)),
        ],
      ),
    );
  }

  Widget _pacienteCard(_ResumenPaciente r) {
    final p = r.p;
    final inic = p.nombre.trim().isEmpty
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
            border: Border.all(color: const Color(0xFFEFECFF))),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, gradient: PlatTheme.purpleGradient),
              child: Center(
                  child: Text(inic,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16))),
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
                  const SizedBox(height: 5),
                  if (r.reporte.promedio != null)
                    Row(
                      children: [
                        if (r.ultima != null) ...[
                          Text(r.ultima!.estado.emoji,
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 6),
                        ],
                        Text('Semana: ',
                            style: const TextStyle(
                                color: PlatTheme.textGray, fontSize: 12)),
                        Text(r.reporte.etiqueta,
                            style: TextStyle(
                                color: r.reporte.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ],
                    )
                  else
                    const Text('Sin registros esta semana',
                        style: TextStyle(
                            color: PlatTheme.textGray, fontSize: 12)),
                ],
              ),
            ),
            if (r.reporte.promedio != null) ...[
              Column(
                children: [
                  Text('${r.reporte.promedio}',
                      style: TextStyle(
                          color: r.reporte.color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const Text('/100',
                      style:
                          TextStyle(color: PlatTheme.textGray, fontSize: 10)),
                ],
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right_rounded, color: PlatTheme.textGray),
          ],
        ),
      ),
    );
  }

  Widget _citaMini(CitaReal c) {
    final video = c.modalidad == 'Videollamada';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEFECFF))),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, gradient: PlatTheme.purpleGradient),
            child: Center(
                child: Text(
                    c.pacienteNombre.isNotEmpty
                        ? c.pacienteNombre[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.pacienteNombre.isNotEmpty ? c.pacienteNombre : 'Paciente',
                    style: const TextStyle(
                        color: PlatTheme.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                if (c.motivo.isNotEmpty)
                  Text(c.motivo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: PlatTheme.textGray, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(c.hora,
                  style: const TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              Row(
                children: [
                  Icon(video ? Icons.videocam_rounded : Icons.place_rounded,
                      size: 12, color: PlatTheme.textGray),
                  const SizedBox(width: 3),
                  Text(c.estado == 'confirmada' ? 'Confirmada' : 'Agendada',
                      style: TextStyle(
                          color: c.estado == 'confirmada'
                              ? const Color(0xFF059669)
                              : PlatTheme.purple,
                          fontSize: 11)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Diario del paciente (solo lectura) ───────────────────────────────────────

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
    if (mounted) setState(() { _notas = notas; _cargando = false; });
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      HistoriaClinicaScreen(paciente: widget.paciente))),
              icon: const Icon(Icons.folder_shared_rounded,
                  color: Colors.white, size: 18),
              label: const Text('Historia clínica',
                  style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
          ),
        ],
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
                      borderRadius: BorderRadius.circular(12)),
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
                const SizedBox(height: 16),
                _reporteSemanalCard(calcularReporteSemanal(_notas)),
                const SizedBox(height: 18),
                const Text('Notas del diario',
                    style: TextStyle(
                        color: PlatTheme.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (_notas.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text('Este paciente aún no tiene notas.',
                          style: TextStyle(
                              color: PlatTheme.textGray, fontSize: 14)),
                    ),
                  )
                else
                  ..._notas.map(_notaCard),
              ],
            ),
    );
  }

  Widget _reporteSemanalCard(ReporteSemanal r) {
    const nombresDia = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEFECFF))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Reporte semanal',
                  style: TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              if (r.promedio != null) ...[
                Text('${r.promedio}',
                    style: TextStyle(
                        color: r.color,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const Text(' /100',
                    style: TextStyle(color: PlatTheme.textGray, fontSize: 12)),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(color: r.color, shape: BoxShape.circle)),
              const SizedBox(width: 7),
              Text(r.etiqueta,
                  style: TextStyle(
                      color: r.color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${r.registros} registros',
                  style:
                      const TextStyle(color: PlatTheme.textGray, fontSize: 11.5)),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: r.dias.map((dia) {
                final tiene = dia.puntaje != null;
                final altura = tiene ? (dia.puntaje! / 100 * 86) : 4.0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (tiene)
                      Text(dia.estado!.emoji,
                          style: const TextStyle(fontSize: 13))
                    else
                      const SizedBox(height: 16),
                    const SizedBox(height: 4),
                    Container(
                      width: 26,
                      height: altura,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: tiene
                              ? dia.estado!.color
                              : const Color(0xFFE8E4FF)),
                    ),
                    const SizedBox(height: 6),
                    Text(nombresDia[dia.fecha.weekday - 1],
                        style: const TextStyle(
                            color: PlatTheme.textGray, fontSize: 11)),
                  ],
                );
              }).toList(),
            ),
          ),
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
          border: Border.all(color: const Color(0xFFEFECFF))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: n.estado.bgSuave,
                    borderRadius: BorderRadius.circular(20)),
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
