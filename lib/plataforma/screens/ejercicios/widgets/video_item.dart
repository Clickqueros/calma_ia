import 'package:flutter/material.dart';
import '../models/ejercicio_model.dart';

class VideoItem extends StatefulWidget {
  final VideoEjercicio video;
  final int index;
  final bool completado;
  final List<Color> gradiente;
  final VoidCallback onTap;

  const VideoItem({
    super.key,
    required this.video,
    required this.index,
    required this.gradiente,
    this.completado = false,
    required this.onTap,
  });

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered
                  ? widget.gradiente.first.withValues(alpha: 0.3)
                  : const Color(0xFFEEEBFF),
            ),
            boxShadow: [
              BoxShadow(
                color: _hovered
                    ? widget.gradiente.first.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: _hovered ? 16 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildThumbnail(),
              Expanded(child: _buildInfo()),
              _buildPlayBtn(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 100,
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.gradiente,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomLeft: Radius.circular(15),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle pattern
          Positioned(
            right: -8,
            bottom: -8,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          // Video number
          Positioned(
            top: 8,
            left: 10,
            child: Text(
              widget.index.toString().padLeft(2, '0'),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Play / check icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(
                  alpha: widget.completado ? 0.95 : (_hovered ? 0.9 : 0.75)),
            ),
            child: Icon(
              widget.completado
                  ? Icons.check_rounded
                  : Icons.play_arrow_rounded,
              color: widget.completado
                  ? widget.gradiente.first
                  : widget.gradiente.first,
              size: 18,
            ),
          ),
          // Duration badge
          Positioned(
            bottom: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.video.duracion,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.video.titulo,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF1A1A2E),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.schedule_rounded,
                  size: 12,
                  color: const Color(0xFF6B7280).withValues(alpha: 0.7)),
              const SizedBox(width: 4),
              Text(
                '${widget.video.duracion} min',
                style: const TextStyle(
                    color: Color(0xFF6B7280), fontSize: 12),
              ),
              const SizedBox(width: 12),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.completado
                      ? widget.gradiente.first
                      : const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                widget.completado ? 'Completado' : 'Disponible',
                style: TextStyle(
                  color: widget.completado
                      ? widget.gradiente.first
                      : const Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayBtn() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: _hovered
              ? LinearGradient(colors: widget.gradiente)
              : null,
          color: _hovered
              ? null
              : widget.gradiente.first.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.play_arrow_rounded,
          color: _hovered ? Colors.white : widget.gradiente.first,
          size: 20,
        ),
      ),
    );
  }
}
