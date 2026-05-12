import 'package:flutter/material.dart';
import '../models/nota_model.dart';

class NotaCard extends StatefulWidget {
  final NotaDiario nota;
  final VoidCallback onEliminar;
  final VoidCallback onVer;

  const NotaCard({
    super.key,
    required this.nota,
    required this.onEliminar,
    required this.onVer,
  });

  @override
  State<NotaCard> createState() => _NotaCardState();
}

class _NotaCardState extends State<NotaCard> {
  bool _hovered = false;

  NotaDiario get n => widget.nota;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hovered
                ? n.estado.color.withValues(alpha: 0.35)
                : const Color(0xFFEEEBFF),
          ),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? n.estado.color.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: _hovered ? 20 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildContent(),
              const SizedBox(height: 16),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Estado badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: n.estado.bgSuave,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: n.estado.color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(n.estado.emoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 5),
              Text(n.estado.label,
                  style: TextStyle(
                      color: n.estado.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const Spacer(),
        // Date + time
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatearFecha(n.fecha),
              style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
            Text(
              formatearHora(n.fecha),
              style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (n.titulo.isNotEmpty) ...[
          Text(
            n.titulo,
            style: const TextStyle(
              color: Color(0xFF1A1A2E),
              fontSize: 15,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Text(
          n.contenido,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF4B5563),
            fontSize: 14,
            height: 1.55,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        _actionBtn(
          label: 'Ver nota completa',
          icon: Icons.open_in_new_rounded,
          color: const Color(0xFF6B4EFF),
          filled: false,
          onTap: widget.onVer,
        ),
        const Spacer(),
        _actionBtn(
          label: 'Eliminar',
          icon: Icons.delete_outline_rounded,
          color: const Color(0xFFEF4444),
          filled: false,
          onTap: () => _confirmarEliminar(),
        ),
      ],
    );
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: filled ? Colors.white : color),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    color: filled ? Colors.white : color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminar() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('¿Eliminar nota?',
            style: TextStyle(
                color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold)),
        content: const Text(
          'Esta acción no se puede deshacer.',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF9CA3AF))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onEliminar();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
