import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import '../data/demo_data.dart';
import 'paciente_detalle_screen.dart';

class PacientesScreen extends StatelessWidget {
  const PacientesScreen({super.key});

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
          Row(
            children: [
              const Text('Pacientes',
                  style: TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: const Color(0xFFF0EEFF),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('${pacientesDemo.length} en total',
                    style: const TextStyle(
                        color: PlatTheme.purple,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Selecciona un paciente para ver su perfil completo.',
              style: TextStyle(color: PlatTheme.textGray, fontSize: 15)),
          const SizedBox(height: 22),
          ...pacientesDemo.map((p) => _pacienteCard(context, p, small)),
        ],
      ),
    );
  }

  Widget _pacienteCard(BuildContext context, PacienteDemo p, bool small) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PacienteDetalleScreen(paciente: p)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEFECFF)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: p.gradiente),
              ),
              child: Center(
                child: Text(p.iniciales,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(p.nombre,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: PlatTheme.textDark,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      _badge(p.estado.label, p.estado.color),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(p.motivoConsulta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: PlatTheme.textGray, fontSize: 12.5)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.event_repeat_rounded,
                          size: 13, color: PlatTheme.textGray),
                      const SizedBox(width: 4),
                      Text('${p.sesionesCompletadas} sesiones',
                          style: const TextStyle(
                              color: PlatTheme.textGray, fontSize: 12)),
                      const SizedBox(width: 14),
                      if (p.proximaCita != null) ...[
                        Icon(Icons.schedule_rounded,
                            size: 13, color: PlatTheme.purple),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(p.proximaCita!,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: PlatTheme.purple,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ] else
                        const Text('Sin próxima cita',
                            style: TextStyle(
                                color: Color(0xFFDC2626), fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            if (!small)
              const Icon(Icons.chevron_right_rounded,
                  color: PlatTheme.textGray),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6)),
        child: Text(text,
            style: TextStyle(
                color: color, fontSize: 10.5, fontWeight: FontWeight.w700)),
      );
}
