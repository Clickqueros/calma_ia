import 'terapeuta_model.dart';

class Cita {
  final Terapeuta terapeuta;
  final DateTime fecha;
  final String hora;
  final String meetLink;

  const Cita({
    required this.terapeuta,
    required this.fecha,
    required this.hora,
    this.meetLink = 'https://meet.google.com/abc-demo-calmaia',
  });
}

// ── Helpers ──────────────────────────────────────────────────────────────────

const _meses = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
];

const _diasSemana = [
  'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
];

String formatearFechaCita(DateTime d) =>
    '${_diasSemana[d.weekday - 1]}, ${d.day} de ${_meses[d.month - 1]} ${d.year}';

String nombreMes(int mes) => _meses[mes - 1];

// ── Availability logic ────────────────────────────────────────────────────────
// Deterministic "booked" slots based on date, so they're consistent per session.

bool esDiaDisponible(DateTime dia) {
  final hoy = DateTime.now();
  final hoyNorm = DateTime(hoy.year, hoy.month, hoy.day);
  if (dia.isBefore(hoyNorm) || dia.isAtSameMomentAs(hoyNorm)) return false;
  if (dia.weekday == DateTime.saturday || dia.weekday == DateTime.sunday) return false;
  // "Block" some days to look realistic (every alt-Tuesday + every 3rd Thursday)
  final semana = ((dia.day - 1) ~/ 7);
  if (dia.weekday == DateTime.tuesday && semana % 2 == 0) return false;
  if (dia.weekday == DateTime.thursday && semana % 3 == 1) return false;
  return true;
}

List<(String hora, bool disponible)> horariosParaFecha(DateTime fecha) {
  const todos = [
    '8:00 AM', '9:30 AM', '11:00 AM', '2:00 PM', '4:30 PM', '6:00 PM'
  ];
  // Block 2 slots deterministically using day number
  final b1 = fecha.day % todos.length;
  final b2 = (fecha.day + 3) % todos.length;
  return todos.asMap().entries
      .map((e) => (e.value, e.key != b1 && e.key != b2))
      .toList();
}
