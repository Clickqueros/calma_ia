import 'package:flutter/material.dart';
import '../../theme/plat_theme.dart';
import '../../../core/animo/animo_service.dart';

/// Reporte semanal de ánimo (0-10): gráfica de 7 días + promedio.
/// Carga el historial del paciente indicado.
class AnimoReporteSemanal extends StatefulWidget {
  final String pacienteId;
  const AnimoReporteSemanal({super.key, required this.pacienteId});

  @override
  State<AnimoReporteSemanal> createState() => _AnimoReporteSemanalState();
}

class _AnimoReporteSemanalState extends State<AnimoReporteSemanal> {
  ReporteAnimo? _reporte;
  bool _cargando = true;

  static const _nombresDia = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void didUpdateWidget(AnimoReporteSemanal old) {
    super.didUpdateWidget(old);
    if (old.pacienteId != widget.pacienteId) _cargar();
  }

  Future<void> _cargar() async {
    final hist = await AnimoService.instance.historial(widget.pacienteId);
    if (mounted) {
      setState(() {
        _reporte = calcularReporteAnimo(hist);
        _cargando = false;
      });
    }
  }

  Color _color(num n) {
    if (n <= 3) return const Color(0xFFDC2626);
    if (n <= 6) return const Color(0xFFD97706);
    return const Color(0xFF059669);
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const SizedBox(
        height: 60,
        child: Center(
            child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5))),
      );
    }
    final r = _reporte!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFECFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.thermostat_rounded,
                  color: PlatTheme.purple, size: 20),
              const SizedBox(width: 8),
              const Text('Ánimo semanal',
                  style: TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              if (r.promedio != null) ...[
                Text(r.promedio!.toStringAsFixed(1),
                    style: TextStyle(
                        color: _color(r.promedio!),
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const Text(' /10',
                    style: TextStyle(color: PlatTheme.textGray, fontSize: 12)),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: r.promedio == null
                        ? PlatTheme.textGray
                        : _color(r.promedio!),
                    shape: BoxShape.circle),
              ),
              const SizedBox(width: 7),
              Text(r.etiqueta,
                  style: TextStyle(
                      color: r.promedio == null
                          ? PlatTheme.textGray
                          : _color(r.promedio!),
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${r.registros} de 7 días',
                  style:
                      const TextStyle(color: PlatTheme.textGray, fontSize: 11.5)),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: r.dias.map((d) {
                final tiene = d.nivel != null;
                final altura = tiene ? (d.nivel! / 10 * 84) : 4.0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (tiene)
                      Text('${d.nivel}',
                          style: TextStyle(
                              color: _color(d.nivel!),
                              fontSize: 11,
                              fontWeight: FontWeight.w700))
                    else
                      const SizedBox(height: 14),
                    const SizedBox(height: 4),
                    Container(
                      width: 24,
                      height: altura,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: tiene
                            ? _color(d.nivel!)
                            : const Color(0xFFE8E4FF),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(_nombresDia[d.fecha.weekday - 1],
                        style: const TextStyle(
                            color: PlatTheme.textGray, fontSize: 11)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
