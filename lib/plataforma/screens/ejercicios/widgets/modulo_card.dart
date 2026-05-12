import 'package:flutter/material.dart';
import '../models/ejercicio_model.dart';

class ModuloCard extends StatefulWidget {
  final Modulo modulo;
  final VoidCallback onTap;

  const ModuloCard({super.key, required this.modulo, required this.onTap});

  @override
  State<ModuloCard> createState() => _ModuloCardState();
}

class _ModuloCardState extends State<ModuloCard> {
  bool _hovered = false;

  Modulo get m => widget.modulo;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hovered ? -4.0 : 0.0, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _hovered
                  ? m.gradiente.first.withValues(alpha: 0.4)
                  : const Color(0xFFEEEBFF),
            ),
            boxShadow: [
              BoxShadow(
                color: _hovered
                    ? m.gradiente.first.withValues(alpha: 0.14)
                    : const Color(0x08000000),
                blurRadius: _hovered ? 28 : 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTop(),
              _buildBody(),
              _buildBottom(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Gradient top banner ──────────────────────────────────────────────────

  Widget _buildTop() {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: m.gradiente,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
      ),
      child: Stack(
        children: [
          // Background glow blob
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Icon(m.icono, color: Colors.white, size: 24),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_circle_outline_rounded,
                          color: Colors.white, size: 13),
                      const SizedBox(width: 4),
                      Text('${m.videos.length} videos',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Content body ─────────────────────────────────────────────────────────

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: m.bgSuave,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              m.etiqueta,
              style: TextStyle(
                color: m.gradiente.last,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            m.titulo,
            style: const TextStyle(
              color: Color(0xFF1A1A2E),
              fontSize: 17,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            m.descripcion,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          // Progress
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${m.videosCompletados}/${m.videos.length} completados',
                          style: TextStyle(
                            color: m.gradiente.first.withValues(alpha: 0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${(m.progreso * 100).toInt()}%',
                          style: TextStyle(
                            color: m.gradiente.first,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: m.progreso,
                        minHeight: 5,
                        backgroundColor:
                            m.gradiente.first.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            m.gradiente.first),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── CTA button ────────────────────────────────────────────────────────────

  Widget _buildBottom() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: SizedBox(
        width: double.infinity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hovered
                  ? m.gradiente
                  : [
                      m.gradiente.first.withValues(alpha: 0.09),
                      m.gradiente.last.withValues(alpha: 0.09),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                m.progreso == 0 ? 'Comenzar módulo' : 'Continuar',
                style: TextStyle(
                  color: _hovered ? Colors.white : m.gradiente.first,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_rounded,
                size: 15,
                color: _hovered ? Colors.white : m.gradiente.first,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
