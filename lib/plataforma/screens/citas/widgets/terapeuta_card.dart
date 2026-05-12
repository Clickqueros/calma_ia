import 'package:flutter/material.dart';
import '../models/terapeuta_model.dart';

class TerapeutaCard extends StatefulWidget {
  final Terapeuta terapeuta;
  final bool seleccionado;
  final VoidCallback onSeleccionar;

  const TerapeutaCard({
    super.key,
    required this.terapeuta,
    required this.seleccionado,
    required this.onSeleccionar,
  });

  @override
  State<TerapeutaCard> createState() => _TerapeutaCardState();
}

class _TerapeutaCardState extends State<TerapeutaCard> {
  bool _hovered = false;

  Terapeuta get t => widget.terapeuta;

  @override
  Widget build(BuildContext context) {
    final sel = widget.seleccionado;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onSeleccionar,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          transform: Matrix4.translationValues(0, _hovered && !sel ? -3 : 0, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: sel
                  ? t.gradiente.first.withValues(alpha: 0.6)
                  : _hovered
                      ? t.gradiente.first.withValues(alpha: 0.25)
                      : const Color(0xFFEEEBFF),
              width: sel ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: sel
                    ? t.gradiente.first.withValues(alpha: 0.15)
                    : _hovered
                        ? Colors.black.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.04),
                blurRadius: sel ? 24 : (_hovered ? 16 : 8),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTop(),
                const SizedBox(height: 14),
                _buildDesc(),
                const SizedBox(height: 14),
                _buildEnfoques(),
                const SizedBox(height: 16),
                _buildBtn(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTop() {
    return Row(
      children: [
        // Avatar
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: t.gradiente),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: t.gradiente.first.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Center(
            child: Text(
              t.iniciales,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.nombre,
                  style: const TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(t.titulo,
                  style: const TextStyle(
                      color: Color(0xFF6B7280), fontSize: 12)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFF59E0B), size: 13),
                  const SizedBox(width: 3),
                  Text('${t.rating}',
                      style: const TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  Text('· ${t.sesiones} sesiones',
                      style: const TextStyle(
                          color: Color(0xFF9CA3AF), fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesc() {
    return Text(
      t.descripcion,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
          color: Color(0xFF4B5563), fontSize: 13, height: 1.5),
    );
  }

  Widget _buildEnfoques() {
    return Wrap(
      spacing: 6,
      children: t.enfoques
          .map((e) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: t.gradiente.first.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(e,
                    style: TextStyle(
                        color: t.gradiente.first,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ))
          .toList(),
    );
  }

  Widget _buildBtn() {
    final sel = widget.seleccionado;
    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: sel
                ? t.gradiente
                : [
                    t.gradiente.first.withValues(alpha: 0.1),
                    t.gradiente.last.withValues(alpha: 0.1)
                  ],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              sel ? Icons.check_rounded : Icons.arrow_forward_rounded,
              size: 15,
              color: sel ? Colors.white : t.gradiente.first,
            ),
            const SizedBox(width: 6),
            Text(
              sel ? 'Seleccionado' : 'Seleccionar',
              style: TextStyle(
                color: sel ? Colors.white : t.gradiente.first,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
