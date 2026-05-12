import 'package:flutter/material.dart';
import '../models/nota_model.dart';

class EstadoSelector extends StatelessWidget {
  final EstadoEmocional? seleccionado;
  final ValueChanged<EstadoEmocional> onSeleccionar;

  const EstadoSelector({
    super.key,
    required this.seleccionado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    final small = MediaQuery.of(context).size.width < 600;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: EstadoEmocional.values.map((e) {
        final selected = seleccionado == e;
        return GestureDetector(
          onTap: () => onSeleccionar(e),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: small ? 12 : 16,
              vertical: small ? 8 : 10,
            ),
            decoration: BoxDecoration(
              color: selected ? e.color : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: selected ? e.color : const Color(0xFFE5E7EB),
                width: selected ? 2 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: e.color.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.emoji,
                    style: TextStyle(fontSize: small ? 14 : 16)),
                const SizedBox(width: 6),
                Text(
                  e.label,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF4B5563),
                    fontSize: small ? 12 : 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
