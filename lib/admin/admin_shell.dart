import 'package:flutter/material.dart';
import '../plataforma/theme/plat_theme.dart';
import 'dashboard/admin_dashboard_screen.dart';
import 'agenda/agenda_screen.dart';
import 'pacientes/pacientes_screen.dart';
import 'tareas/tareas_screen.dart';
import 'recursos/recursos_admin_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AdminShell — contenedor del panel del psicólogo.
//
// Reutiliza el patrón responsive de la app del paciente:
//   width < 900  → AppBar + BottomNav (móvil)
//   width >= 900 → Sidebar fija (escritorio)
//
// NO toca el flujo del paciente. Es un "mundo" aparte al que se entra
// desde el botón "Portal Psicólogos" de la landing.
// ─────────────────────────────────────────────────────────────────────────────

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selected = 0;

  static const _navItems = [
    (Icons.grid_view_rounded, 'Dashboard'),
    (Icons.calendar_month_rounded, 'Agenda'),
    (Icons.people_alt_rounded, 'Pacientes'),
    (Icons.assignment_rounded, 'Tareas'),
    (Icons.folder_copy_rounded, 'Recursos'),
  ];

  bool get _small => MediaQuery.of(context).size.width < 900;

  Widget get _content => switch (_selected) {
        1 => const AgendaScreen(),
        2 => const PacientesScreen(),
        3 => const TareasScreen(),
        4 => const RecursosAdminScreen(),
        _ => const AdminDashboardScreen(),
      };

  @override
  Widget build(BuildContext context) {
    if (_small) {
      return Scaffold(
        backgroundColor: PlatTheme.softBg,
        appBar: _buildMobileAppBar(),
        body: _content,
        bottomNavigationBar: _buildBottomNav(),
      );
    }
    return Scaffold(
      backgroundColor: PlatTheme.softBg,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _content),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Top bar (desktop) ──────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEFECFF))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: PlatTheme.softBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE8E4FF)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search_rounded, size: 18, color: PlatTheme.textGray),
                  SizedBox(width: 10),
                  Text('Buscar paciente...',
                      style: TextStyle(color: PlatTheme.textGray, fontSize: 14)),
                ],
              ),
            ),
          ),
          const Spacer(),
          _iconButton(Icons.notifications_none_rounded, badge: true),
          const SizedBox(width: 12),
          _avatar(),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, {bool badge = false}) {
    return Stack(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: PlatTheme.softBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE8E4FF)),
          ),
          child: Icon(icon, size: 20, color: PlatTheme.textDark),
        ),
        if (badge)
          Positioned(
            right: 9,
            top: 9,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFDC2626),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _avatar() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: PlatTheme.purpleGradient,
          ),
          child: const Center(
            child: Text('MG',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Dra. María González',
                style: TextStyle(
                    color: PlatTheme.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            Text('Psicóloga Clínica',
                style: TextStyle(color: PlatTheme.textGray, fontSize: 11)),
          ],
        ),
      ],
    );
  }

  // ── Sidebar (desktop) ──────────────────────────────────────────────────────

  Widget _buildSidebar() {
    return Container(
      width: 256,
      color: PlatTheme.darkNavy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 8),
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
              child: const Text('PANEL PROFESIONAL',
                  style: TextStyle(
                      color: PlatTheme.softBlue,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2)),
            ),
          ),
          const SizedBox(height: 28),
          _sidebarLabel('GESTIÓN'),
          const SizedBox(height: 8),
          ..._navItems.asMap().entries
              .map((e) => _navItem(e.key, e.value.$1, e.value.$2)),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: _navItem(98, Icons.help_outline_rounded, 'Ayuda'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded,
                        color: const Color.fromRGBO(255, 255, 255, 0.75),
                        size: 20),
                    const SizedBox(width: 12),
                    Text('Salir del panel',
                        style: TextStyle(
                            color: const Color.fromRGBO(255, 255, 255, 0.92),
                            fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarLabel(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(text,
            style: const TextStyle(
                color: Color.fromRGBO(255, 255, 255, 0.6),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4)),
      );

  Widget _navItem(int index, IconData icon, String label) {
    final selected = _selected == index;
    return GestureDetector(
      onTap: () => setState(() => _selected = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: selected
              ? const Color.fromRGBO(107, 78, 255, 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? const Color.fromRGBO(107, 78, 255, 0.4)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected
                    ? PlatTheme.softPurple
                    : const Color.fromRGBO(255, 255, 255, 0.75),
                size: 20),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    color: selected
                        ? Colors.white
                        : const Color.fromRGBO(255, 255, 255, 0.92),
                    fontSize: 14,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400)),
            if (selected) ...[
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: PlatTheme.softPurple),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Mobile ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: PlatTheme.darkNavy,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: Colors.white54, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, gradient: PlatTheme.purpleGradient),
            child: const Icon(Icons.self_improvement,
                color: Colors.white, size: 15),
          ),
          const SizedBox(width: 8),
          const Text('Panel',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, gradient: PlatTheme.purpleGradient),
          child: const Center(
            child: Text('MG',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    // En móvil mostramos los 4 más usados (Recursos queda fuera del bottom-nav).
    final items = _navItems.take(4).toList();
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
            children: items.asMap().entries.map((e) {
              final selected = _selected == e.key;
              return GestureDetector(
                onTap: () => setState(() => _selected = e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color.fromRGBO(107, 78, 255, 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(e.value.$1,
                          color: selected
                              ? PlatTheme.softPurple
                              : const Color.fromRGBO(255, 255, 255, 0.6),
                          size: 22),
                      const SizedBox(height: 4),
                      Text(e.value.$2,
                          style: TextStyle(
                              color: selected
                                  ? PlatTheme.softPurple
                                  : const Color.fromRGBO(255, 255, 255, 0.6),
                              fontSize: 10,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w400)),
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
}
