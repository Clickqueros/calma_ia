import 'package:flutter/material.dart';
import '../theme/plat_theme.dart';

class OpcionCard extends StatelessWidget {
  final String texto;
  final bool seleccionada;
  final VoidCallback onTap;

  const OpcionCard({
    super.key,
    required this.texto,
    required this.seleccionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: seleccionada
              ? Color.fromRGBO(107, 78, 255, 0.07)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionada ? PlatTheme.purple : const Color(0xFFE8E4FF),
            width: seleccionada ? 2.0 : 1.0,
          ),
          boxShadow: seleccionada
              ? [BoxShadow(color: Color.fromRGBO(107, 78, 255, 0.12), blurRadius: 14, offset: const Offset(0, 4))]
              : [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: seleccionada ? PlatTheme.purple : Colors.transparent,
                border: Border.all(
                  color: seleccionada ? PlatTheme.purple : const Color(0xFFD1CCFF),
                  width: 2,
                ),
              ),
              child: seleccionada
                  ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(
                  color: seleccionada ? PlatTheme.purple : PlatTheme.textDark,
                  fontSize: 15,
                  fontWeight: seleccionada ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
