import 'package:flutter/material.dart';
import 'models/ejercicio_model.dart';
import 'widgets/modulo_card.dart';
import 'modulo_screen.dart';

class EjerciciosScreen extends StatelessWidget {
  const EjerciciosScreen({super.key});

  bool _small(BuildContext ctx) => MediaQuery.of(ctx).size.width < 800;

  @override
  Widget build(BuildContext context) {
    final small = _small(context);
    final pad = small ? 20.0 : 48.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(small),
          const SizedBox(height: 36),
          _buildStatsRow(context),
          const SizedBox(height: 36),
          _buildSectionLabel(),
          const SizedBox(height: 20),
          _buildGrid(context, small, pad),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(bool small) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDDD6FE)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fitness_center_rounded,
                      size: 13, color: Color(0xFF7C3AED)),
                  SizedBox(width: 6),
                  Text('5 módulos disponibles',
                      style: TextStyle(
                          color: Color(0xFF7C3AED),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Ejercicios Guiados',
          style: TextStyle(
            color: const Color(0xFF1A1A2E),
            fontSize: small ? 26 : 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Módulos de ejercicios emocionales para la ansiedad\ny la regulación emocional, guiados por expertos.',
          style: TextStyle(
              color: Color(0xFF6B7280), fontSize: 15, height: 1.6),
        ),
      ],
    );
  }

  // ── Stats row ──────────────────────────────────────────────────────────────

  Widget _buildStatsRow(BuildContext context) {
    final double totalProgress = modulosData.fold(
            0.0, (sum, m) => sum + m.progreso) /
        modulosData.length;
    final int videosTotal =
        modulosData.fold(0, (sum, m) => sum + m.videos.length);
    final int videosComp = modulosData.fold(
        0, (sum, m) => sum + m.videosCompletados);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D0A35), Color(0xFF2D1B69)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(child: _statItem('$videosComp/$videosTotal', 'Videos vistos', Icons.play_circle_outline_rounded)),
          _divider(),
          Expanded(child: _statItem('${(totalProgress * 100).toInt()}%', 'Progreso total', Icons.trending_up_rounded)),
          _divider(),
          Expanded(child: _statItem('${modulosData.length}', 'Módulos activos', Icons.grid_view_rounded)),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white54, size: 18),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11)),
      ],
    );
  }

  Widget _divider() {
    return Container(
        width: 1, height: 40, color: Colors.white.withValues(alpha: 0.12));
  }

  Widget _buildSectionLabel() {
    return const Row(
      children: [
        Text('Todos los módulos',
            style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        SizedBox(width: 10),
        Text('· ordenados por categoría',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
      ],
    );
  }

  // ── Responsive grid ────────────────────────────────────────────────────────

  Widget _buildGrid(BuildContext context, bool small, double pad) {
    if (small) {
      return Column(
        children: modulosData
            .map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ModuloCard(
                    modulo: m,
                    onTap: () => _goToModulo(context, m),
                  ),
                ))
            .toList(),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      final cols = constraints.maxWidth > 900 ? 3 : 2;
      final gap = 20.0;
      final cardW = (constraints.maxWidth - gap * (cols - 1)) / cols;

      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: modulosData
            .map((m) => SizedBox(
                  width: cardW,
                  child: ModuloCard(
                    modulo: m,
                    onTap: () => _goToModulo(context, m),
                  ),
                ))
            .toList(),
      );
    });
  }

  void _goToModulo(BuildContext context, Modulo modulo) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, anim, _) => ModuloScreen(modulo: modulo),
        transitionsBuilder: (ctx, anim, _, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
                    begin: const Offset(0.04, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}
