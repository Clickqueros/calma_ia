import 'package:flutter/material.dart';

enum EstadoEmocional {
  tranquilo('Tranquilo/a', '😌', Color(0xFF10B981), Color(0xFFF0FDF4)),
  ansioso('Ansioso/a', '😰', Color(0xFFF59E0B), Color(0xFFFFFBEB)),
  triste('Triste', '😔', Color(0xFF6B7280), Color(0xFFF9FAFB)),
  cansado('Cansado/a', '😮‍💨', Color(0xFF8B5CF6), Color(0xFFF5F3FF)),
  agradecido('Agradecido/a', '🙏', Color(0xFFD97706), Color(0xFFFFF7ED)),
  esperanzado('Esperanzado/a', '🌱', Color(0xFF059669), Color(0xFFECFDF5));

  final String label;
  final String emoji;
  final Color color;
  final Color bgSuave;

  const EstadoEmocional(this.label, this.emoji, this.color, this.bgSuave);
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
