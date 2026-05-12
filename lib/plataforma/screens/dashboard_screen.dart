import 'package:flutter/material.dart';
import '../theme/plat_theme.dart';
import 'recursos/recursos_screen.dart';
import 'respiracion/respiracion_screen.dart';
import 'ejercicios/ejercicios_screen.dart';
import 'diario/diario_screen.dart';
import 'citas/citas_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedNav = 0;

  static const _navItems = [
    (Icons.home_rounded, 'Inicio'),
    (Icons.fitness_center_rounded, 'Ejercicios'),
    (Icons.calendar_month_rounded, 'Citas'),
    (Icons.menu_book_rounded, 'Recursos'),
    (Icons.edit_note_rounded, 'Diario'),
  ];

  bool get _small => MediaQuery.of(context).size.width < 800;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlatTheme.softBg,
      body: _small ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  // ── Layouts ────────────────────────────────────────────────────────────────

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildSidebar(),
        Expanded(child: _buildMainContent()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: PlatTheme.softBg,
      appBar: _buildMobileAppBar(),
      body: _buildMainContent(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Mobile AppBar ──────────────────────────────────────────────────────────

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: PlatTheme.darkNavy,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: PlatTheme.purpleGradient,
            ),
            child: const Icon(Icons.self_improvement, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          const Text('calma',
              style: TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: PlatTheme.purpleGradient,
          ),
          child: const Center(
            child: Text('E',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
        ),
      ],
    );
  }

  // ── Bottom Navigation ──────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: PlatTheme.darkNavy,
        border: Border(top: BorderSide(color: Color(0xFF2D2460), width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navItems.asMap().entries.map((e) {
              final selected = _selectedNav == e.key;
              return GestureDetector(
                onTap: () => setState(() => _selectedNav = e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? Color.fromRGBO(107, 78, 255, 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        e.value.$1,
                        color: selected
                            ? PlatTheme.softPurple
                            : Color.fromRGBO(176, 191, 255, 0.5),
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.value.$2,
                        style: TextStyle(
                          color: selected
                              ? PlatTheme.softPurple
                              : Color.fromRGBO(176, 191, 255, 0.5),
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
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

  // ── Sidebar (desktop only) ─────────────────────────────────────────────────

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: PlatTheme.darkNavy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sidebarLogo(),
          _sidebarProfile(),
          const SizedBox(height: 28),
          _sidebarLabel('MENÚ'),
          const SizedBox(height: 8),
          ..._navItems.asMap().entries
              .map((e) => _navItem(e.key, e.value.$1, e.value.$2)),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
            child: _navItem(99, Icons.settings_rounded, 'Configuración'),
          ),
        ],
      ),
    );
  }

  Widget _sidebarLogo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, gradient: PlatTheme.purpleGradient),
            child:
                const Icon(Icons.self_improvement, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text('calma',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _sidebarProfile() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color.fromRGBO(107, 78, 255, 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color.fromRGBO(107, 78, 255, 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, gradient: PlatTheme.purpleGradient),
            child: const Center(
              child: Text('E',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Explorador',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Text('Bienestar activo',
                    style:
                        TextStyle(color: PlatTheme.softBlue, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        text,
        style: TextStyle(
          color: Color.fromRGBO(176, 191, 255, 0.5),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final selected = _selectedNav == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedNav = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: selected
              ? Color.fromRGBO(107, 78, 255, 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? Color.fromRGBO(107, 78, 255, 0.4)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? PlatTheme.softPurple
                  : Color.fromRGBO(176, 191, 255, 0.55),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : Color.fromRGBO(176, 191, 255, 0.65),
                fontSize: 14,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (selected) ...[
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: PlatTheme.softPurple),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Main content router ────────────────────────────────────────────────────

  Widget _buildMainContent() {
    return switch (_selectedNav) {
      1 => const EjerciciosScreen(),
      2 => const CitasScreen(),
      3 => const RecursosScreen(),
      4 => const DiarioScreen(),
      _ => _buildInicio(),
    };
  }

  void _irARespirar(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondary) =>
            const RespiracionScreen(),
        transitionsBuilder: (context, anim, secondary, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  // ── Inicio ─────────────────────────────────────────────────────────────────

  Widget _buildInicio() {
    final pad = _small ? 20.0 : 48.0;
    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEncabezado(),
          const SizedBox(height: 32),
          _buildStatCards(),
          const SizedBox(height: 32),
          _buildSesionesRecientes(),
          const SizedBox(height: 32),
          _buildSesionHoy(),
          const SizedBox(height: 32),
          _buildSeccionProgreso(),
        ],
      ),
    );
  }

  // ── Sesiones recientes ──────────────────────────────────────────────────────

  static final _sesionesRecientes = [
    _SesionItem(
      titulo: 'Interpretando Síntomas de Ansiedad',
      categoria: 'PROGRAMA',
      duracion: '12:15',
      progreso: 0.14,
      gradiente: const [Color(0xFFB45309), Color(0xFFD97706)],
      icono: Icons.lightbulb_rounded,
    ),
    _SesionItem(
      titulo: 'Técnicas de Calma Inmediata',
      categoria: 'REGULACIÓN',
      duracion: '7:30',
      progreso: 1.0,
      gradiente: const [Color(0xFF065F46), Color(0xFF059669)],
      icono: Icons.balance_rounded,
    ),
    _SesionItem(
      titulo: 'Regulación Emocional con Mindfulness',
      categoria: 'MINDFULNESS',
      duracion: '10:20',
      progreso: 0.4,
      gradiente: const [Color(0xFF5B21B6), Color(0xFF7C3AED)],
      icono: Icons.self_improvement,
    ),
    _SesionItem(
      titulo: 'Respiración Diafragmática',
      categoria: 'RESPIRACIÓN',
      duracion: '8:15',
      progreso: 1.0,
      gradiente: const [Color(0xFF0891B2), Color(0xFF06B6D4)],
      icono: Icons.air_rounded,
    ),
    _SesionItem(
      titulo: 'Exposición Gradual a Sensaciones',
      categoria: 'EXPOSICIÓN',
      duracion: '12:00',
      progreso: 0.0,
      gradiente: const [Color(0xFFBE185D), Color(0xFFEC4899)],
      icono: Icons.favorite_rounded,
    ),
  ];

  Widget _buildSesionesRecientes() {
    final cardW = _small ? 160.0 : 200.0;
    final cardH = _small ? 148.0 : 175.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sesiones recientes',
          style: TextStyle(
              color: PlatTheme.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Contenido que has visto recientemente',
          style: TextStyle(color: PlatTheme.textGray, fontSize: 13),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: cardH + 72,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _sesionesRecientes.length,
            itemBuilder: (ctx, i) {
              final s = _sesionesRecientes[i];
              return _sesionCard(s, cardW, cardH);
            },
          ),
        ),
      ],
    );
  }

  Widget _sesionCard(_SesionItem s, double w, double h) {
    return Container(
      width: w,
      margin: const EdgeInsets.only(right: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: s.gradiente,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Background icon (decorative)
                  Positioned(
                    right: -14,
                    bottom: -14,
                    child: Icon(s.icono,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  // Dark gradient overlay (bottom)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Category badge (top-left)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        s.categoria,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  // Bottom: progress + label
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress % or duration
                        Row(
                          children: [
                            if (s.progreso > 0 && s.progreso < 1.0)
                              Text(
                                '${(s.progreso * 100).round()}%',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700),
                              )
                            else if (s.progreso == 1.0)
                              const Row(
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      color: Colors.white, size: 12),
                                  SizedBox(width: 4),
                                  Text('100%',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700)),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Icon(Icons.schedule_rounded,
                                      color: Colors.white.withValues(alpha: 0.8),
                                      size: 11),
                                  const SizedBox(width: 4),
                                  Text(
                                    s.duracion,
                                    style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: s.progreso,
                            minHeight: 3,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Title below card
          Text(
            s.titulo,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: PlatTheme.textDark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            s.duracion,
            style: const TextStyle(
                color: PlatTheme.textGray, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildEncabezado() {
    if (_small) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('☀️  Buenos días, Explorador',
              style: TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Este es tu espacio de calma.',
              style: TextStyle(color: PlatTheme.textGray, fontSize: 14)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: PlatTheme.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text('Meditar ahora',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('☀️  Buenos días, Explorador',
                  style: TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 30,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Este es tu espacio de calma. Hoy es un buen día para cuidarte.',
                  style: TextStyle(color: PlatTheme.textGray, fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(width: 24),
        ElevatedButton.icon(
          onPressed: () => _irARespirar(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: PlatTheme.purple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          icon: const Icon(Icons.play_arrow_rounded, size: 20),
          label: const Text('Meditar ahora',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    final cards = [
      _statCard(Icons.local_fire_department_rounded, const Color(0xFFFF6B9D),
          'Tu racha', '5 días', '¡Sigue así!',
          const Color(0xFFFFF0F5), const Color(0xFFFFD6E7)),
      _statCard(Icons.self_improvement, PlatTheme.purple,
          'Sesiones', '3 completadas', 'Esta semana',
          const Color(0xFFF0EEFF), const Color(0xFFD4CAFF)),
      _statCard(Icons.favorite_rounded, const Color(0xFF00BCD4),
          'Bienestar', '72 / 100', 'Índice general',
          const Color(0xFFE8FAFB), const Color(0xFFB2EDF5)),
    ];

    if (_small) {
      return Column(
        children: cards
            .map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: c,
                ))
            .toList(),
      );
    }

    return Row(
      children: [
        Expanded(child: cards[0]),
        const SizedBox(width: 20),
        Expanded(child: cards[1]),
        const SizedBox(width: 20),
        Expanded(child: cards[2]),
      ],
    );
  }

  Widget _statCard(IconData icon, Color iconColor, String label, String valor,
      String detalle, Color bg, Color border) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: PlatTheme.textGray, fontSize: 12)),
                Text(valor,
                    style: const TextStyle(
                        color: PlatTheme.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(detalle,
                    style: const TextStyle(
                        color: PlatTheme.textGray, fontSize: 11)),
              ],
            ),
          ),
          Icon(Icons.arrow_upward_rounded, size: 14, color: iconColor),
        ],
      ),
    );
  }

  Widget _buildSesionHoy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sesión de hoy',
            style: TextStyle(
                color: PlatTheme.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        Container(
          padding: EdgeInsets.all(_small ? 20 : 32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [PlatTheme.darkNavy, Color(0xFF2D1B69)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: _small ? _sesionMobile() : _sesionDesktop(),
        ),
      ],
    );
  }

  Widget _sesionMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Color.fromRGBO(107, 78, 255, 0.32),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Recomendado para ti',
              style: TextStyle(
                  color: PlatTheme.softBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ),
        const SizedBox(height: 14),
        const Text('Meditación de bienvenida y calma',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.3)),
        const SizedBox(height: 8),
        const Text('Una sesión suave para comenzar tu camino',
            style: TextStyle(color: PlatTheme.softBlue, fontSize: 13)),
        const SizedBox(height: 16),
        Row(
          children: [
            _sesionTag(Icons.schedule_rounded, '10 min'),
            const SizedBox(width: 10),
            _sesionTag(Icons.signal_cellular_alt_rounded, 'Principiante'),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: PlatTheme.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text('Comenzar sesión',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _sesionDesktop() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(107, 78, 255, 0.32),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Recomendado para ti',
                    style: TextStyle(
                        color: PlatTheme.softBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 18),
              const Text('Meditación de\nbienvenida y calma',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3)),
              const SizedBox(height: 8),
              const Text('Una sesión suave para comenzar tu camino',
                  style: TextStyle(
                      color: PlatTheme.softBlue, fontSize: 14)),
              const SizedBox(height: 20),
              Row(
                children: [
                  _sesionTag(Icons.schedule_rounded, '10 min'),
                  const SizedBox(width: 12),
                  _sesionTag(
                      Icons.signal_cellular_alt_rounded, 'Principiante'),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: PlatTheme.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Comenzar sesión',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Color.fromRGBO(107, 78, 255, 0.35), width: 1.5),
              ),
            ),
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(107, 78, 255, 0.2),
                border: Border.all(
                    color: Color.fromRGBO(107, 78, 255, 0.5), width: 2),
              ),
              child: const Icon(Icons.self_improvement,
                  color: Colors.white, size: 56),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sesionTag(IconData icon, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: PlatTheme.softBlue),
          const SizedBox(width: 5),
          Text(texto,
              style: const TextStyle(
                  color: PlatTheme.softBlue, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSeccionProgreso() {
    if (_small) {
      return _accionesRapidas();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _progresoSemanal()),
        const SizedBox(width: 24),
        Expanded(flex: 2, child: _accionesRapidas()),
      ],
    );
  }

  Widget _progresoSemanal() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Progreso semanal',
                  style: TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: PlatTheme.softBg,
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('Esta semana',
                    style: TextStyle(
                        color: PlatTheme.textGray, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _barra('L', 0.40, false),
              _barra('M', 0.70, false),
              _barra('X', 0.50, false),
              _barra('J', 0.90, false),
              _barra('V', 0.60, true),
              _barra('S', 0.30, false),
              _barra('D', 0.00, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _barra(String dia, double ratio, bool hoy) {
    const maxH = 100.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          width: 28,
          height: ratio == 0 ? 4 : maxH * ratio,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: ratio > 0
                ? (hoy
                    ? const LinearGradient(
                        colors: [PlatTheme.purple, PlatTheme.softPurple],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFE8E4FF), Color(0xFFD4CAFF)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ))
                : null,
            color: ratio == 0 ? const Color(0xFFE8E4FF) : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(dia,
            style: TextStyle(
              color: hoy ? PlatTheme.purple : PlatTheme.textGray,
              fontSize: 11,
              fontWeight:
                  hoy ? FontWeight.w700 : FontWeight.normal,
            )),
      ],
    );
  }

  Widget _accionesRapidas() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Acciones rápidas',
              style: TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...[
            (Icons.nightlight_round, 'Meditación para dormir', '8 min'),
            (Icons.air_rounded, 'Ejercicio de respiración', '3 min'),
            (Icons.edit_note_rounded, 'Escribir en mi diario', '5 min'),
            (Icons.headphones_rounded, 'Sonidos de naturaleza', 'Libre'),
          ].map((t) => _accionItem(t.$1, t.$2, t.$3)),
        ],
      ),
    );
  }

  Widget _accionItem(IconData icon, String titulo, String duracion) {
    return GestureDetector(
      onTap: titulo == 'Escribir en mi diario'
          ? () => setState(() => _selectedNav = 4)
          : titulo == 'Ejercicio de respiración'
              ? () => _irARespirar(context)
              : null,
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PlatTheme.softBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E4FF)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [PlatTheme.purple, PlatTheme.softPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(titulo,
                style: const TextStyle(
                    color: PlatTheme.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
          Text(duracion,
              style: const TextStyle(
                  color: PlatTheme.textGray, fontSize: 12)),
        ],
      ),
    ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4))
        ],
      ),
      child: child,
    );
  }
}

// ── Data model for recent sessions ──────────────────────────────────────────

class _SesionItem {
  final String titulo;
  final String categoria;
  final String duracion;
  final double progreso;
  final List<Color> gradiente;
  final IconData icono;

  const _SesionItem({
    required this.titulo,
    required this.categoria,
    required this.duracion,
    required this.progreso,
    required this.gradiente,
    required this.icono,
  });
}
