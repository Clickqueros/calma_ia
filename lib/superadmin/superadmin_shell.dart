import 'package:flutter/material.dart';
import '../plataforma/theme/plat_theme.dart';
import 'dashboard/superadmin_dashboard_screen.dart';
import 'patients/patients_admin_screen.dart';
import 'audit/audit_screen.dart';
import 'access_requests/access_requests_screen.dart';
import 'asignaciones/asignaciones_screen.dart';
import 'psychologists/gestion_psicologos_screen.dart';
import 'appointments/citas_admin_screen.dart';
import 'widgets/status_badge.dart';
import '../core/auth/auth_service.dart';
import '../core/supabase/supabase_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SuperAdminShell — panel del dueño de la plataforma.
//
// Sidebar con 3 secciones (GENERAL · NEGOCIO · SEGURIDAD Y PRIVACIDAD).
// La sección sensible se diferencia visualmente (acento ámbar + candado).
// En móvil: drawer (13 módulos no caben en bottom-nav).
// ─────────────────────────────────────────────────────────────────────────────

class _Item {
  final int index;
  final IconData icon;
  final String label;
  const _Item(this.index, this.icon, this.label);
}

class SuperAdminShell extends StatefulWidget {
  const SuperAdminShell({super.key});

  @override
  State<SuperAdminShell> createState() => _SuperAdminShellState();
}

class _SuperAdminShellState extends State<SuperAdminShell> {
  int _selected = 0;

  static const _general = [
    _Item(0, Icons.grid_view_rounded, 'Dashboard'),
    _Item(1, Icons.medical_services_rounded, 'Psicólogos'),
    _Item(2, Icons.people_alt_rounded, 'Pacientes'),
    _Item(13, Icons.link_rounded, 'Asignaciones'),
    _Item(3, Icons.apartment_rounded, 'Clínicas'),
    _Item(4, Icons.event_note_rounded, 'Citas'),
  ];
  static const _negocio = [
    _Item(5, Icons.workspace_premium_rounded, 'Suscripciones'),
    _Item(6, Icons.article_rounded, 'Contenido'),
    _Item(7, Icons.folder_copy_rounded, 'Recursos'),
    _Item(8, Icons.support_agent_rounded, 'Soporte'),
  ];
  static const _seguridad = [
    _Item(9, Icons.fact_check_rounded, 'Auditoría'),
    _Item(10, Icons.security_rounded, 'Seguridad'),
    _Item(11, Icons.key_rounded, 'Solicitudes de acceso'),
    _Item(12, Icons.settings_rounded, 'Configuración'),
  ];

  bool get _small => MediaQuery.of(context).size.width < 900;

  String get _titulo => [
        ..._general, ..._negocio, ..._seguridad
      ].firstWhere((i) => i.index == _selected).label;

  Widget get _content => switch (_selected) {
        0 => const SuperAdminDashboardScreen(),
        1 => const GestionPsicologosScreen(),
        2 => const PatientsAdminScreen(),
        4 => const CitasAdminScreen(),
        13 => const AsignacionesScreen(),
        9 => const AuditScreen(),
        11 => const AccessRequestsScreen(),
        _ => _enConstruccion(),
      };

  Widget _enConstruccion() => EmptyState(
        icono: Icons.construction_rounded,
        titulo: 'Módulo "$_titulo"',
        subtitulo: 'Disponible en la siguiente fase del panel.',
      );

  @override
  Widget build(BuildContext context) {
    if (_small) {
      return Scaffold(
        backgroundColor: PlatTheme.softBg,
        drawer: Drawer(
          backgroundColor: PlatTheme.darkNavy,
          child: SafeArea(child: _sidebarContent(isDrawer: true)),
        ),
        appBar: AppBar(
          backgroundColor: PlatTheme.darkNavy,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(_titulo,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
        ),
        body: _content,
      );
    }
    return Scaffold(
      backgroundColor: PlatTheme.softBg,
      body: Row(
        children: [
          SizedBox(width: 264, child: _sidebarContent()),
          Expanded(
            child: Column(
              children: [
                _topBar(),
                Expanded(child: _content),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────────────────

  Widget _topBar() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEFECFF))),
      ),
      child: Row(
        children: [
          Text(_titulo,
              style: const TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: 19,
                  fontWeight: FontWeight.bold)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EEFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_rounded, size: 14, color: PlatTheme.purple),
                SizedBox(width: 6),
                Text('SuperAdmin',
                    style: TextStyle(
                        color: PlatTheme.purple,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Sidebar ──────────────────────────────────────────────────────────────

  Widget _sidebarContent({bool isDrawer = false}) {
    return Container(
      color: PlatTheme.darkNavy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 6),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, gradient: PlatTheme.purpleGradient),
                  child: const Icon(Icons.shield_rounded,
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
              child: const Text('PANEL SUPERADMIN',
                  style: TextStyle(
                      color: PlatTheme.softBlue,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2)),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _seccion('GENERAL', _general, isDrawer),
                  const SizedBox(height: 18),
                  _seccion('NEGOCIO', _negocio, isDrawer),
                  const SizedBox(height: 18),
                  _seccion('SEGURIDAD Y PRIVACIDAD', _seguridad, isDrawer,
                      sensible: true),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final nav = Navigator.of(context);
              if (SupabaseConfig.isConfigured &&
                  AuthService.instance.haySesion) {
                await AuthService.instance.cerrarSesion();
              }
              nav.maybePop();
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(28, 14, 24, 20),
              child: Row(
                children: [
                  const Icon(Icons.logout_rounded,
                      color: Color(0xFFFF8A8A), size: 20),
                  const SizedBox(width: 12),
                  const Text('Cerrar sesión',
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

  Widget _seccion(String titulo, List<_Item> items, bool isDrawer,
      {bool sensible = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              if (sensible) ...[
                const Icon(Icons.lock_rounded,
                    size: 11, color: Color(0xFFFBBF24)),
                const SizedBox(width: 5),
              ],
              Text(titulo,
                  style: TextStyle(
                      color: sensible
                          ? const Color(0xFFFBBF24)
                          : const Color.fromRGBO(255, 255, 255, 0.6),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((it) => _navItem(it, isDrawer, sensible: sensible)),
      ],
    );
  }

  Widget _navItem(_Item it, bool isDrawer, {bool sensible = false}) {
    final selected = _selected == it.index;
    final accent = sensible ? const Color(0xFFFBBF24) : PlatTheme.softPurple;
    return GestureDetector(
      onTap: () {
        setState(() => _selected = it.index);
        if (isDrawer) Navigator.of(context).pop();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? Color.fromRGBO(
                  sensible ? 251 : 107, sensible ? 191 : 78,
                  sensible ? 36 : 255, sensible ? 0.16 : 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? accent.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(it.icon,
                color: selected
                    ? accent
                    : const Color.fromRGBO(255, 255, 255, 0.75),
                size: 19),
            const SizedBox(width: 12),
            Expanded(
              child: Text(it.label,
                  style: TextStyle(
                      color: selected
                          ? Colors.white
                          : const Color.fromRGBO(255, 255, 255, 0.92),
                      fontSize: 13.5,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400)),
            ),
            if (selected)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: accent),
              ),
          ],
        ),
      ),
    );
  }
}
