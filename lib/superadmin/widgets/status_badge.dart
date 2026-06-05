import 'package:flutter/material.dart';

/// Badge de estado estandarizado para todo el panel SuperAdmin.
enum BadgeStatus {
  activo('Activo', Color(0xFF059669)),
  inactivo('Inactivo', Color(0xFF6B7280)),
  pendiente('Pendiente', Color(0xFFD97706)),
  bloqueado('Bloqueado', Color(0xFFDC2626)),
  atencion('Requiere atención', Color(0xFF6B4EFF));

  final String label;
  final Color color;
  const BadgeStatus(this.label, this.color);
}

class StatusBadge extends StatelessWidget {
  final BadgeStatus status;
  final String? customLabel;
  const StatusBadge(this.status, {super.key, this.customLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
                color: status.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(customLabel ?? status.label,
              style: TextStyle(
                  color: status.color,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Estado vacío bien diseñado, reutilizable.
class EmptyState extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? subtitulo;
  const EmptyState(
      {super.key, required this.icono, required this.titulo, this.subtitulo});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EEFF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icono, size: 34, color: const Color(0xFF6B4EFF)),
            ),
            const SizedBox(height: 18),
            Text(titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            if (subtitulo != null) ...[
              const SizedBox(height: 6),
              Text(subtitulo!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}
