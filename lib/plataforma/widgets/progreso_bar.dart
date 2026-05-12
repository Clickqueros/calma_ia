import 'package:flutter/material.dart';
import '../theme/plat_theme.dart';

class ProgresoBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgresoBar({super.key, required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep + 1) / totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pregunta ${currentStep + 1} de $totalSteps',
              style: const TextStyle(color: PlatTheme.textGray, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Text(
              '${(progress * 100).toInt()}% completado',
              style: const TextStyle(color: PlatTheme.purple, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFE8E4FF),
            valueColor: const AlwaysStoppedAnimation<Color>(PlatTheme.purple),
          ),
        ),
      ],
    );
  }
}
