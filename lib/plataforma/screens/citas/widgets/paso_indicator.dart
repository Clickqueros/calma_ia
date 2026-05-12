import 'package:flutter/material.dart';

class PasoIndicator extends StatelessWidget {
  final int pasoActual;
  final List<String> pasos;

  const PasoIndicator({
    super.key,
    required this.pasoActual,
    required this.pasos,
  });

  static const _purple = Color(0xFF6B4EFF);

  @override
  Widget build(BuildContext context) {
    final small = MediaQuery.of(context).size.width < 600;
    return Row(
      children: pasos.asMap().entries.map((e) {
        final i = e.key;
        final label = e.value;
        final completed = i < pasoActual;
        final current = i == pasoActual;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: completed || current ? _purple : Colors.white,
                        border: Border.all(
                          color: completed || current
                              ? _purple
                              : const Color(0xFFE5E7EB),
                          width: 2,
                        ),
                        boxShadow: current
                            ? [
                                BoxShadow(
                                  color: _purple.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                )
                              ]
                            : [],
                      ),
                      child: Center(
                        child: completed
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 16)
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: current
                                      ? Colors.white
                                      : const Color(0xFF9CA3AF),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    if (!small) ...[
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: TextStyle(
                          color: current || completed
                              ? _purple
                              : const Color(0xFF9CA3AF),
                          fontSize: 11,
                          fontWeight: current
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Connector line
              if (i < pasos.length - 1)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: 2,
                    margin: EdgeInsets.only(bottom: small ? 0 : 20),
                    color: completed ? _purple : const Color(0xFFE5E7EB),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
