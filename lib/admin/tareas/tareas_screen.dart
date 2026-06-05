import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import '../data/demo_data.dart';

class TareasScreen extends StatelessWidget {
  const TareasScreen({super.key});

  bool _small(BuildContext c) => MediaQuery.of(c).size.width < 900;

  @override
  Widget build(BuildContext context) {
    final small = _small(context);
    final pad = small ? 20.0 : 36.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tareas terapéuticas',
              style: TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Asigna tareas a tus pacientes y revisa sus respuestas.',
              style: TextStyle(color: PlatTheme.textGray, fontSize: 15)),
          const SizedBox(height: 22),

          // Asignadas
          const Text('Asignadas recientemente',
              style: TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          ...tareasDemo.map((t) => _tareaAsignada(t)),
          const SizedBox(height: 28),

          // Biblioteca
          const Text('Biblioteca de tareas frecuentes',
              style: TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Plantillas listas para asignar con un clic.',
              style: TextStyle(color: PlatTheme.textGray, fontSize: 13)),
          const SizedBox(height: 16),
          _bibliotecaGrid(context, small),
        ],
      ),
    );
  }

  Widget _tareaAsignada(TareaDemo t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEFECFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (t.completada
                      ? const Color(0xFF059669)
                      : const Color(0xFFD97706))
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              t.completada ? Icons.check_circle_rounded : Icons.pending_rounded,
              color: t.completada
                  ? const Color(0xFF059669)
                  : const Color(0xFFD97706),
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.titulo,
                    style: const TextStyle(
                        color: PlatTheme.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${t.pacienteNombre} · ${t.fechaLimite}',
                    style: const TextStyle(
                        color: PlatTheme.textGray, fontSize: 12)),
              ],
            ),
          ),
          if (t.completada)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                  color: const Color(0xFFF0EEFF),
                  borderRadius: BorderRadius.circular(8)),
              child: const Text('Revisar',
                  style: TextStyle(
                      color: PlatTheme.purple,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  Widget _bibliotecaGrid(BuildContext context, bool small) {
    final cols = small ? 1 : 2;
    return GridView.count(
      crossAxisCount: cols,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: small ? 4.6 : 4.2,
      children: bibliotecaTareas.map((b) => _plantilla(context, b)).toList(),
    );
  }

  Widget _plantilla(BuildContext context, (IconData, String, String) b) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Asignar "${b.$2}" a un paciente (demo)'),
          backgroundColor: PlatTheme.darkNavy,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEFECFF)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: PlatTheme.purpleGradient,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(b.$1, color: Colors.white, size: 21),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(b.$2,
                      style: const TextStyle(
                          color: PlatTheme.textDark,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(b.$3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: PlatTheme.textGray, fontSize: 11.5)),
                ],
              ),
            ),
            const Icon(Icons.add_circle_outline_rounded,
                color: PlatTheme.purple, size: 20),
          ],
        ),
      ),
    );
  }
}
