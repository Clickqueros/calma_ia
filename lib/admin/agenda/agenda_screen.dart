import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import '../data/demo_data.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  int _filtro = 0; // 0 Hoy · 1 Próximas · 2 Completadas · 3 Canceladas

  static const _filtros = ['Hoy', 'Próximas', 'Completadas', 'Canceladas'];

  bool _small(BuildContext c) => MediaQuery.of(c).size.width < 900;

  List<CitaDemo> get _citasFiltradas {
    final n = DateTime.now();
    bool esHoy(DateTime d) => d.year == n.year && d.month == n.month && d.day == n.day;
    switch (_filtro) {
      case 0:
        return citasDemo.where((c) => esHoy(c.fecha)).toList();
      case 1:
        return citasDemo
            .where((c) =>
                c.fecha.isAfter(DateTime(n.year, n.month, n.day)) &&
                c.estado == EstadoCita.agendada)
            .toList();
      case 2:
        return citasDemo.where((c) => c.estado == EstadoCita.completada).toList();
      case 3:
        return citasDemo.where((c) => c.estado == EstadoCita.cancelada).toList();
      default:
        return citasDemo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final small = _small(context);
    final pad = small ? 20.0 : 36.0;
    final citas = _citasFiltradas;

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Agenda',
              style: TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Gestiona tus citas: reagenda, cancela o inicia la sesión.',
              style: TextStyle(color: PlatTheme.textGray, fontSize: 15)),
          const SizedBox(height: 22),
          _tabs(),
          const SizedBox(height: 20),
          if (citas.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_available_rounded,
                        size: 48, color: PlatTheme.textGray.withValues(alpha: 0.4)),
                    const SizedBox(height: 12),
                    Text('No hay citas en "${_filtros[_filtro]}"',
                        style: const TextStyle(color: PlatTheme.textGray)),
                  ],
                ),
              ),
            )
          else
            ...citas.map((c) => _citaCard(context, c, small)),
        ],
      ),
    );
  }

  Widget _tabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filtros.asMap().entries.map((e) {
          final sel = _filtro == e.key;
          return GestureDetector(
            onTap: () => setState(() => _filtro = e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: sel ? PlatTheme.purple : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: sel ? PlatTheme.purple : const Color(0xFFE8E4FF)),
              ),
              child: Text(e.value,
                  style: TextStyle(
                      color: sel ? Colors.white : PlatTheme.textGray,
                      fontSize: 13.5,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w500)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _citaCard(BuildContext context, CitaDemo c, bool small) {
    final videollamada = c.modalidad == 'Videollamada';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFECFF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: c.gradiente),
                ),
                child: Center(
                  child: Text(c.pacienteIniciales,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
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
                          child: Text(c.pacienteNombre,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: PlatTheme.textDark,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        _badge(c.estado.label, c.estado.color),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(c.motivo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: PlatTheme.textGray, fontSize: 12.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFFF2F0FF)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 15, color: PlatTheme.textGray),
              const SizedBox(width: 5),
              Text(c.hora,
                  style: const TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              Icon(videollamada ? Icons.videocam_rounded : Icons.place_rounded,
                  size: 15, color: PlatTheme.textGray),
              const SizedBox(width: 5),
              Text(c.modalidad,
                  style: const TextStyle(
                      color: PlatTheme.textGray, fontSize: 13)),
              const Spacer(),
              if (c.estado == EstadoCita.agendada) ...[
                if (!small) ...[
                  _accion(context, 'Reagendar', false, () => _toast(context, 'Reagendar cita (demo)')),
                  const SizedBox(width: 8),
                  _accion(context, 'Iniciar sesión', true, () => _toast(context, 'Iniciar videollamada (demo)')),
                ] else
                  _accion(context, 'Iniciar', true, () => _toast(context, 'Iniciar sesión (demo)')),
              ],
            ],
          ),
        ],
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

  Widget _accion(BuildContext context, String label, bool primary, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: primary ? PlatTheme.purple : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
              color: primary ? PlatTheme.purple : const Color(0xFFE8E4FF)),
        ),
        child: Text(label,
            style: TextStyle(
                color: primary ? Colors.white : PlatTheme.textGray,
                fontSize: 12.5,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: PlatTheme.darkNavy,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
