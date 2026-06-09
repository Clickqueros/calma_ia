import 'package:flutter/material.dart';

enum EstadoEmocional {
  // El último número es el PUNTAJE de bienestar (0-100) de ese estado.
  tranquilo('Tranquilo/a', '😌', Color(0xFF10B981), Color(0xFFF0FDF4), 80),
  ansioso('Ansioso/a', '😰', Color(0xFFF59E0B), Color(0xFFFFFBEB), 35),
  triste('Triste', '😔', Color(0xFF6B7280), Color(0xFFF9FAFB), 25),
  cansado('Cansado/a', '😮‍💨', Color(0xFF8B5CF6), Color(0xFFF5F3FF), 50),
  agradecido('Agradecido/a', '🙏', Color(0xFFD97706), Color(0xFFFFF7ED), 90),
  esperanzado('Esperanzado/a', '🌱', Color(0xFF059669), Color(0xFFECFDF5), 85);

  final String label;
  final String emoji;
  final Color color;
  final Color bgSuave;
  final int puntaje;

  const EstadoEmocional(
      this.label, this.emoji, this.color, this.bgSuave, this.puntaje);
}

// ── Reporte semanal de bienestar ─────────────────────────────────────────────

class DiaReporte {
  final DateTime fecha;
  final EstadoEmocional? estado; // null si no hubo registro ese día
  final int? puntaje;
  const DiaReporte(this.fecha, this.estado, this.puntaje);
}

class ReporteSemanal {
  final List<DiaReporte> dias; // últimos 7 días (orden ascendente)
  final int? promedio; // 0-100, null si no hay datos
  final int registros;

  const ReporteSemanal(
      {required this.dias, required this.promedio, required this.registros});

  String get etiqueta {
    if (promedio == null) return 'Sin datos';
    if (promedio! >= 70) return 'Se ha sentido bien';
    if (promedio! >= 50) return 'Altibajos';
    return 'Semana difícil';
  }

  Color get color {
    if (promedio == null) return const Color(0xFF9CA3AF);
    if (promedio! >= 70) return const Color(0xFF059669);
    if (promedio! >= 50) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }
}

/// Calcula el reporte de los últimos 7 días a partir de las notas.
ReporteSemanal calcularReporteSemanal(List<NotaDiario> notas) {
  final ahora = DateTime.now();
  final inicio =
      DateTime(ahora.year, ahora.month, ahora.day).subtract(const Duration(days: 6));

  bool mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  final recientes = notas.where((n) {
    final d = DateTime(n.fecha.year, n.fecha.month, n.fecha.day);
    return !d.isBefore(inicio);
  }).toList();

  final dias = <DiaReporte>[];
  for (var i = 0; i < 7; i++) {
    final dia = inicio.add(Duration(days: i));
    final delDia = recientes.where((n) => mismoDia(n.fecha, dia)).toList();
    if (delDia.isEmpty) {
      dias.add(DiaReporte(dia, null, null));
    } else {
      final prom = (delDia.map((n) => n.estado.puntaje).reduce((a, b) => a + b) /
              delDia.length)
          .round();
      dias.add(DiaReporte(dia, delDia.first.estado, prom));
    }
  }

  final todos = recientes.map((n) => n.estado.puntaje).toList();
  final promedio = todos.isEmpty
      ? null
      : (todos.reduce((a, b) => a + b) / todos.length).round();

  return ReporteSemanal(
      dias: dias, promedio: promedio, registros: recientes.length);
}

class NotaDiario {
  final String id;
  final String titulo;
  final String contenido;
  final EstadoEmocional estado;
  final DateTime fecha;

  const NotaDiario({
    required this.id,
    required this.titulo,
    required this.contenido,
    required this.estado,
    required this.fecha,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'contenido': contenido,
        'estado': estado.name,
        'fecha': fecha.toIso8601String(),
      };

  factory NotaDiario.fromJson(Map<String, dynamic> json) => NotaDiario(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        contenido: json['contenido'] as String,
        estado: EstadoEmocional.values.firstWhere(
          (e) => e.name == json['estado'],
          orElse: () => EstadoEmocional.tranquilo,
        ),
        fecha: DateTime.parse(json['fecha'] as String),
      );
}

// ── Date helper ─────────────────────────────────────────────────────────────

String formatearFecha(DateTime fecha) {
  final now = DateTime.now();
  final hoy = DateTime(now.year, now.month, now.day);
  final diaFecha = DateTime(fecha.year, fecha.month, fecha.day);
  final diff = hoy.difference(diaFecha).inDays;

  if (diff == 0) return 'Hoy';
  if (diff == 1) return 'Ayer';

  const meses = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
  ];
  return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
}

String formatearHora(DateTime fecha) {
  final h = fecha.hour.toString().padLeft(2, '0');
  final m = fecha.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
