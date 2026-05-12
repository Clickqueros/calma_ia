import 'package:flutter/material.dart';
import 'models/ejercicio_model.dart';
import 'widgets/video_item.dart';
import 'video_player_screen.dart';

class ModuloScreen extends StatelessWidget {
  final Modulo modulo;
  const ModuloScreen({super.key, required this.modulo});

  bool _small(BuildContext ctx) => MediaQuery.of(ctx).size.width < 700;

  @override
  Widget build(BuildContext context) {
    final small = _small(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(child: _buildHeader(context, small)),
            SliverToBoxAdapter(child: _buildVideoList(context, small)),
          ],
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: modulo.gradiente.first,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 16),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: modulo.gradiente,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                right: -30,
                bottom: -30,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Positioned(
                right: 40,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Icon(modulo.icono, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            modulo.etiqueta.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            modulo.titulo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header info ─────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, bool small) {
    return Padding(
      padding: EdgeInsets.all(small ? 20 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            modulo.descripcion,
            style: const TextStyle(
                color: Color(0xFF6B7280), fontSize: 15, height: 1.6),
          ),
          const SizedBox(height: 20),
          // Progress card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEBFF)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      '${modulo.videosCompletados} de ${modulo.videos.length} videos completados',
                      style: TextStyle(
                          color: modulo.gradiente.first,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      '${(modulo.progreso * 100).toInt()}%',
                      style: TextStyle(
                          color: modulo.gradiente.first,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: modulo.progreso,
                    minHeight: 8,
                    backgroundColor:
                        modulo.gradiente.first.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        modulo.gradiente.first),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Contenido del módulo',
            style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontSize: 17,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${modulo.videos.length} videos · Sigue el orden recomendado',
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Video list ──────────────────────────────────────────────────────────

  Widget _buildVideoList(BuildContext context, bool small) {
    return Padding(
      padding: EdgeInsets.fromLTRB(small ? 20 : 32, 0, small ? 20 : 32, 40),
      child: Column(
        children: modulo.videos.asMap().entries.map((e) {
          final completado = e.key < modulo.videosCompletados;
          return VideoItem(
            video: e.value,
            index: e.key + 1,
            gradiente: modulo.gradiente,
            completado: completado,
            onTap: () => Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (ctx, anim, _) => VideoPlayerScreen(
                  video: e.value,
                  modulo: modulo,
                  videoIndex: e.key,
                ),
                transitionsBuilder: (ctx, anim, _, child) =>
                    FadeTransition(opacity: anim, child: child),
                transitionDuration: const Duration(milliseconds: 300),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
