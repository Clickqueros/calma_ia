import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import '../data/demo_data.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  bool _small(BuildContext c) => MediaQuery.of(c).size.width < 900;

  @override
  Widget build(BuildContext context) {
    final small = _small(context);
    final pad = small ? 20.0 : 36.0;
    final citasHoy =
        citasDemo.where((c) => _esHoy(c.fecha) && c.estado == EstadoCita.agendada).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _encabezado(citasHoy.length),
          const SizedBox(height: 28),
          _stats(small),
          const SizedBox(height: 28),
          small
              ? Column(
                  children: [
                    _citasHoyCard(context, citasHoy),
                    const SizedBox(height: 20),
                    _alertasCard(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _citasHoyCard(context, citasHoy)),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: _alertasCard()),
                  ],
                ),
          const SizedBox(height: 20),
          small
              ? Column(
                  children: [
                    _tareasPendientesCard(),
                    const SizedBox(height: 20),
                    _evolucionCard(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _tareasPendientesCard()),
                    const SizedBox(width: 20),
                    Expanded(flex: 3, child: _evolucionCard()),
                  ],
                ),
        ],
      ),
    );
  }

  // ── Encabezado ───────────────────────────────────────────────────────────

  Widget _encabezado(int citasHoy) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Buen día, Dra. González 👋',
            style: TextStyle(
                color: PlatTheme.textDark,
                fontSize: 26,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(
          'Tienes $citasHoy citas programadas para hoy. Aquí está el resumen de tu consulta.',
          style: const TextStyle(color: PlatTheme.textGray, fontSize: 15),
        ),
      ],
    );
  }

  // ── Stats ────────────────────────────────────────────────────────────────

  Widget _stats(bool small) {
    final activos = pacientesDemo.where((p) => p.estado == EstadoProceso.activo).length;
    final tareasPend = tareasDemo.where((t) => !t.completada).length;
    final sinCita = pacientesDemo.where((p) => p.proximaCita == null).length;

    final cards = [
      _stat(Icons.event_available_rounded, const Color(0xFF6B4EFF),
          'Citas hoy', '3', const Color(0xFFF0EEFF)),
      _stat(Icons.people_alt_rounded, const Color(0xFF059669),
          'Pacientes activos', '$activos', const Color(0xFFE8FAF0)),
      _stat(Icons.assignment_late_rounded, const Color(0xFFD97706),
          'Tareas por revisar', '$tareasPend', const Color(0xFFFFF7ED)),
      _stat(Icons.event_busy_rounded, const Color(0xFFDC2626),
          'Sin próxima cita', '$sinCita', const Color(0xFFFEF2F2)),
    ];

    if (small) {
      return Column(
        children: [
          Row(children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: cards[2]),
            const SizedBox(width: 12),
            Expanded(child: cards[3]),
          ]),
        ],
      );
    }
    return Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          Expanded(child: cards[i]),
          if (i < cards.length - 1) const SizedBox(width: 20),
        ],
      ],
    );
  }

  Widget _stat(IconData icon, Color color, String label, String valor, Color bg) {
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
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 14),
          Text(valor,
              style: const TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: PlatTheme.textGray, fontSize: 13)),
        ],
      ),
    );
  }

  // ── Citas de hoy ──────────────────────────────────────────────────────────

  Widget _citasHoyCard(BuildContext context, List<CitaDemo> citas) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.today_rounded, color: PlatTheme.purple, size: 20),
              const SizedBox(width: 10),
              const Text('Citas de hoy',
                  style: TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 17,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFF0EEFF),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('${citas.length} programadas',
                    style: const TextStyle(
                        color: PlatTheme.purple,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (citas.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No tienes citas para hoy 🎉',
                    style: TextStyle(color: PlatTheme.textGray)),
              ),
            )
          else
            ...citas.map((c) => _citaRow(c)),
        ],
      ),
    );
  }

  Widget _citaRow(CitaDemo c) {
    final videollamada = c.modalidad == 'Videollamada';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PlatTheme.softBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEFECFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: c.gradiente),
            ),
            child: Center(
              child: Text(c.pacienteIniciales,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.pacienteNombre,
                    style: const TextStyle(
                        color: PlatTheme.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(c.motivo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: PlatTheme.textGray, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(c.hora,
                  style: const TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(videollamada ? Icons.videocam_rounded : Icons.place_rounded,
                      size: 12, color: PlatTheme.textGray),
                  const SizedBox(width: 3),
                  Text(c.modalidad,
                      style: const TextStyle(
                          color: PlatTheme.textGray, fontSize: 11)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Alertas ──────────────────────────────────────────────────────────────

  Widget _alertasCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_rounded,
                  color: Color(0xFFDC2626), size: 20),
              const SizedBox(width: 10),
              const Text('Alertas',
                  style: TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 17,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('${alertasDemo.length}',
                    style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...alertasDemo.map((a) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PlatTheme.softBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: a.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(a.icono, color: a.color, size: 17),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.texto,
                              style: const TextStyle(
                                  color: PlatTheme.textDark,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 1),
                          Text(a.paciente,
                              style: const TextStyle(
                                  color: PlatTheme.textGray, fontSize: 11.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── Tareas pendientes ─────────────────────────────────────────────────────

  Widget _tareasPendientesCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tareas por revisar',
              style: TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...tareasDemo.map((t) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PlatTheme.softBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEFECFF)),
                ),
                child: Row(
                  children: [
                    Icon(
                      t.completada
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: t.completada
                          ? const Color(0xFF059669)
                          : PlatTheme.textGray,
                      size: 20,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.titulo,
                              style: const TextStyle(
                                  color: PlatTheme.textDark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 1),
                          Text(t.pacienteNombre,
                              style: const TextStyle(
                                  color: PlatTheme.textGray, fontSize: 11.5)),
                        ],
                      ),
                    ),
                    Text(t.completada ? 'Revisar' : t.fechaLimite,
                        style: TextStyle(
                            color: t.completada
                                ? PlatTheme.purple
                                : PlatTheme.textGray,
                            fontSize: 11,
                            fontWeight: t.completada
                                ? FontWeight.w700
                                : FontWeight.w400)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── Evolución general ─────────────────────────────────────────────────────

  Widget _evolucionCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Evolución de pacientes',
              style: TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Nivel de bienestar reportado',
              style: TextStyle(color: PlatTheme.textGray, fontSize: 12.5)),
          const SizedBox(height: 18),
          ...pacientesDemo.take(5).map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: p.gradiente),
                      ),
                      child: Center(
                        child: Text(p.iniciales,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(p.nombre,
                                    style: const TextStyle(
                                        color: PlatTheme.textDark,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                              ),
                              Text('${p.nivelBienestar}%',
                                  style: TextStyle(
                                      color: _colorNivel(p.nivelBienestar),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: p.nivelBienestar / 100,
                              minHeight: 6,
                              backgroundColor: const Color(0xFFEFECFF),
                              valueColor: AlwaysStoppedAnimation(
                                  _colorNivel(p.nivelBienestar)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Color _colorNivel(int n) {
    if (n >= 65) return const Color(0xFF059669);
    if (n >= 50) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEFECFF)),
        ),
        child: child,
      );

  bool _esHoy(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }
}
