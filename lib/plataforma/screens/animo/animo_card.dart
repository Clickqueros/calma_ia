import 'package:flutter/material.dart';
import '../../theme/plat_theme.dart';
import '../../../core/animo/animo_service.dart';
import '../../../core/supabase/supabase_config.dart';

/// Tarjeta del "termómetro de ánimo": el paciente califica su día de 0 a 10.
class AnimoCard extends StatefulWidget {
  const AnimoCard({super.key});

  @override
  State<AnimoCard> createState() => _AnimoCardState();
}

class _AnimoCardState extends State<AnimoCard> {
  int? _nivelHoy;
  int? _seleccion;
  bool _cargando = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final n = await AnimoService.instance.nivelDeHoy();
    if (mounted) {
      setState(() {
        _nivelHoy = n;
        _seleccion = n;
        _cargando = false;
      });
    }
  }

  Future<void> _guardar() async {
    if (_seleccion == null) return;
    setState(() => _guardando = true);
    final err = await AnimoService.instance.guardarHoy(_seleccion!);
    if (!mounted) return;
    setState(() {
      _guardando = false;
      if (err == null) _nivelHoy = _seleccion;
    });
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('¡Registrado! Gracias por cuidarte 💜'),
        backgroundColor: Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Color _colorNivel(int n) {
    if (n <= 3) return const Color(0xFFDC2626); // bajo
    if (n <= 6) return const Color(0xFFD97706); // medio
    return const Color(0xFF059669); // alto
  }

  String _etiqueta(int n) {
    if (n <= 2) return 'Muy bajo';
    if (n <= 4) return 'Bajo';
    if (n <= 6) return 'Regular';
    if (n <= 8) return 'Bien';
    return 'Excelente';
  }

  @override
  Widget build(BuildContext context) {
    // Sin backend no mostramos la tarjeta (necesita guardar de verdad).
    if (!SupabaseConfig.isConfigured) return const SizedBox.shrink();
    if (_cargando) return const SizedBox.shrink();

    final yaCalifico = _nivelHoy != null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PlatTheme.darkNavy, Color(0xFF2D1B69)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.thermostat_rounded,
                  color: Color(0xFFFBBF24), size: 22),
              const SizedBox(width: 8),
              Text(
                  yaCalifico
                      ? 'Tu ánimo de hoy'
                      : '¿Cómo está tu ánimo hoy?',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
              yaCalifico
                  ? 'Puedes ajustarlo si quieres.'
                  : 'Califica del 0 (muy bajo) al 10 (excelente).',
              style: const TextStyle(color: PlatTheme.softBlue, fontSize: 13)),
          const SizedBox(height: 18),
          // Escala 0-10
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(11, (i) {
              final sel = _seleccion == i;
              return GestureDetector(
                onTap: () => setState(() => _seleccion = i),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: sel ? _colorNivel(i) : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: sel
                            ? _colorNivel(i)
                            : Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Center(
                    child: Text('$i',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight:
                                sel ? FontWeight.bold : FontWeight.w500)),
                  ),
                ),
              );
            }),
          ),
          if (_seleccion != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: _colorNivel(_seleccion!),
                      shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text('${_seleccion!}/10 · ${_etiqueta(_seleccion!)}',
                    style: TextStyle(
                        color: _colorNivel(_seleccion!),
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  (_seleccion == null || _guardando || _seleccion == _nivelHoy)
                      ? null
                      : _guardar,
              style: ElevatedButton.styleFrom(
                backgroundColor: PlatTheme.purple,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.15),
                disabledForegroundColor: Colors.white54,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _guardando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : Text(
                      yaCalifico
                          ? (_seleccion == _nivelHoy
                              ? 'Ya registraste hoy ✓'
                              : 'Actualizar')
                          : 'Registrar mi ánimo',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
