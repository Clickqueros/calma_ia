import 'package:flutter/material.dart';
import '../theme/plat_theme.dart';
import 'recursos/recursos_screen.dart';
import 'respiracion/respiracion_screen.dart';
import 'ejercicios/ejercicios_screen.dart';
import 'diario/diario_screen.dart';
import 'citas/citas_screen.dart';
import 'citas/mis_citas_paciente_screen.dart';
import '../../core/supabase/supabase_config.dart';
import '../../core/auth/auth_service.dart';
import '../../core/auth/perfil_service.dart';
import 'animo/animo_card.dart';
import 'animo/animo_reporte_widget.dart';
import 'citas/agendar_cita_real_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedNav = 0;
  String _nombre = '';

  String get _nombreCorto => _nombre.isNotEmpty ? _nombre.split(' ').first : 'Explorador';
  String get _inicial =>
      _nombre.isNotEmpty ? _nombre[0].toUpperCase() : 'E';

  String get _saludo {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días';
    if (h < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  IconData get _saludoIcono {
    final h = DateTime.now().hour;
    if (h >= 19 || h < 5) return Icons.nightlight_round;
    return Icons.wb_sunny_rounded;
  }

  Color get _saludoColor {
    final h = DateTime.now().hour;
    if (h >= 19 || h < 5) return const Color(0xFF6B8CFF); // luna azulada
    if (h < 12) return const Color(0xFFFBBF24); // sol amarillo mañana
    return const Color(0xFFF59E0B); // tarde ámbar
  }

  Widget _saludoWidget(double fontSize) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(_saludoIcono, color: _saludoColor, size: fontSize),
        SizedBox(width: fontSize * 0.35),
        Flexible(
          child: Text('$_saludo, $_nombreCorto',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _cargarNombre();
  }

  Future<void> _cargarNombre() async {
    final perfil = await PerfilService.instance.miPerfil();
    if (mounted && perfil != null) {
      setState(() => _nombre = (perfil['nombre'] as String?) ?? '');
    }
  }

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
        if (SupabaseConfig.isConfigured && AuthService.instance.haySesion)
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded,
                color: Color(0xFFFF8A8A), size: 22),
            onPressed: () async {
              final nav = Navigator.of(context);
              await AuthService.instance.cerrarSesion();
              nav.maybePop();
            },
          ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: PlatTheme.purpleGradient,
          ),
          child: Center(
            child: Text(_inicial,
                style: const TextStyle(
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
                            : Color.fromRGBO(255, 255, 255, 0.6),
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.value.$2,
                        style: TextStyle(
                          color: selected
                              ? PlatTheme.softPurple
                              : Color.fromRGBO(255, 255, 255, 0.6),
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
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: _navItem(99, Icons.settings_rounded, 'Configuración'),
          ),
          if (SupabaseConfig.isConfigured && AuthService.instance.haySesion)
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
            child: Center(
              child: Text(_inicial,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_nombreCorto,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const Text('Bienestar activo',
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
          color: Color.fromRGBO(255, 255, 255, 0.6),
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
                  : Color.fromRGBO(255, 255, 255, 0.75),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : Color.fromRGBO(255, 255, 255, 0.92),
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
      2 => SupabaseConfig.isConfigured
          ? const MisCitasPacienteScreen()
          : const CitasScreen(),
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
          const SizedBox(height: 24),
          const AnimoCard(),
          if (SupabaseConfig.isConfigured &&
              AuthService.instance.usuarioActual != null) ...[
            const SizedBox(height: 16),
            AnimoReporteSemanal(
                pacienteId: AuthService.instance.usuarioActual!.id),
          ],
          const SizedBox(height: 24),
          _buildAccesos(),
        ],
      ),
    );
  }

  // ── Accesos rápidos ─────────────────────────────────────────────────────────
  Widget _buildAccesos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Accesos rápidos',
            style: TextStyle(
                color: PlatTheme.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _accesoCard(
                icon: Icons.event_available_rounded,
                titulo: 'Agendar cita',
                subtitulo: 'Con tu psicólogo',
                colores: const [PlatTheme.purple, PlatTheme.softPurple],
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const AgendarCitaRealScreen())),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _accesoCard(
                icon: Icons.edit_note_rounded,
                titulo: 'Escribir en mi diario',
                subtitulo: 'Registra cómo te sientes',
                colores: const [Color(0xFF0891B2), Color(0xFF06B6D4)],
                onTap: () => setState(() => _selectedNav = 4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _accesoCard({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required List<Color> colores,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEFECFF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colores,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 14),
            Text(titulo,
                style: const TextStyle(
                    color: PlatTheme.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(subtitulo,
                style: const TextStyle(
                    color: PlatTheme.textGray, fontSize: 12.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildEncabezado() {
    if (_small) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _saludoWidget(22),
          const SizedBox(height: 8),
          const Text('Este es tu espacio de calma.',
              style: TextStyle(color: PlatTheme.textGray, fontSize: 14)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _irARespirar(context),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _saludoWidget(30),
              const SizedBox(height: 8),
              const Text('Este es tu espacio de calma. Hoy es un buen día para cuidarte.',
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

}
