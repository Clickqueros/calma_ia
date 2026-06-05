import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATOS DE EJEMPLO (DEMO) para el panel administrativo del psicólogo.
//
// Todo aquí es ficticio y sirve solo para mostrar la plataforma.
// Cuando se conecte el backend (Supabase), estos modelos se reemplazan
// por datos reales sin cambiar las pantallas.
// ─────────────────────────────────────────────────────────────────────────────

// ── Enums ────────────────────────────────────────────────────────────────────

enum EstadoProceso {
  nuevo('Nuevo', Color(0xFF6B4EFF)),
  activo('Activo', Color(0xFF059669)),
  enPausa('En pausa', Color(0xFFD97706)),
  alta('Alta', Color(0xFF6B7280));

  final String label;
  final Color color;
  const EstadoProceso(this.label, this.color);
}

enum EstadoCita {
  agendada('Agendada', Color(0xFF6B4EFF)),
  completada('Completada', Color(0xFF059669)),
  cancelada('Cancelada', Color(0xFFDC2626)),
  noAsistio('No asistió', Color(0xFFD97706));

  final String label;
  final Color color;
  const EstadoCita(this.label, this.color);
}

// ── Modelos ──────────────────────────────────────────────────────────────────

class PacienteDemo {
  final String id;
  final String nombre;
  final String iniciales;
  final int edad;
  final String motivoConsulta;
  final EstadoProceso estado;
  final List<Color> gradiente;
  final int sesionesCompletadas;
  final String? proximaCita;
  final int nivelBienestar; // 0-100
  final String ultimoEstado; // emoji + label
  final String telefono;
  final String email;

  const PacienteDemo({
    required this.id,
    required this.nombre,
    required this.iniciales,
    required this.edad,
    required this.motivoConsulta,
    required this.estado,
    required this.gradiente,
    required this.sesionesCompletadas,
    required this.proximaCita,
    required this.nivelBienestar,
    required this.ultimoEstado,
    required this.telefono,
    required this.email,
  });
}

class CitaDemo {
  final String id;
  final String pacienteId;
  final String pacienteNombre;
  final String pacienteIniciales;
  final List<Color> gradiente;
  final DateTime fecha;
  final String hora;
  final EstadoCita estado;
  final String modalidad; // Videollamada | Presencial
  final String motivo;

  const CitaDemo({
    required this.id,
    required this.pacienteId,
    required this.pacienteNombre,
    required this.pacienteIniciales,
    required this.gradiente,
    required this.fecha,
    required this.hora,
    required this.estado,
    required this.modalidad,
    required this.motivo,
  });
}

class TareaDemo {
  final String id;
  final String pacienteNombre;
  final String titulo;
  final String tipo;
  final bool completada;
  final String fechaLimite;

  const TareaDemo({
    required this.id,
    required this.pacienteNombre,
    required this.titulo,
    required this.tipo,
    required this.completada,
    required this.fechaLimite,
  });
}

class AlertaDemo {
  final String texto;
  final String paciente;
  final IconData icono;
  final Color color;

  const AlertaDemo({
    required this.texto,
    required this.paciente,
    required this.icono,
    required this.color,
  });
}

// ── Paletas reutilizables ────────────────────────────────────────────────────

const _g1 = [Color(0xFF5B21B6), Color(0xFF7C3AED)];
const _g2 = [Color(0xFF0891B2), Color(0xFF06B6D4)];
const _g3 = [Color(0xFFBE185D), Color(0xFFEC4899)];
const _g4 = [Color(0xFF065F46), Color(0xFF059669)];
const _g5 = [Color(0xFFB45309), Color(0xFFD97706)];
const _g6 = [Color(0xFF4338CA), Color(0xFF6366F1)];

// ── Pacientes de ejemplo ─────────────────────────────────────────────────────

const pacientesDemo = <PacienteDemo>[
  PacienteDemo(
    id: 'p1',
    nombre: 'Valentina Restrepo',
    iniciales: 'VR',
    edad: 28,
    motivoConsulta: 'Ansiedad generalizada y estrés laboral',
    estado: EstadoProceso.activo,
    gradiente: _g1,
    sesionesCompletadas: 8,
    proximaCita: 'Hoy, 9:30 AM',
    nivelBienestar: 64,
    ultimoEstado: '😰 Ansiosa',
    telefono: '+57 310 245 8890',
    email: 'valentina.r@email.com',
  ),
  PacienteDemo(
    id: 'p2',
    nombre: 'Andrés Felipe Gómez',
    iniciales: 'AG',
    edad: 35,
    motivoConsulta: 'Duelo por pérdida familiar',
    estado: EstadoProceso.activo,
    gradiente: _g2,
    sesionesCompletadas: 5,
    proximaCita: 'Hoy, 11:00 AM',
    nivelBienestar: 48,
    ultimoEstado: '😔 Triste',
    telefono: '+57 320 118 7745',
    email: 'afgomez@email.com',
  ),
  PacienteDemo(
    id: 'p3',
    nombre: 'Daniela Ospina',
    iniciales: 'DO',
    edad: 24,
    motivoConsulta: 'Crisis de pánico y fobia social',
    estado: EstadoProceso.activo,
    gradiente: _g3,
    sesionesCompletadas: 12,
    proximaCita: 'Mañana, 4:30 PM',
    nivelBienestar: 71,
    ultimoEstado: '🌱 Esperanzada',
    telefono: '+57 315 902 3321',
    email: 'dani.ospina@email.com',
  ),
  PacienteDemo(
    id: 'p4',
    nombre: 'Mateo Hernández',
    iniciales: 'MH',
    edad: 41,
    motivoConsulta: 'Estrés crónico e insomnio',
    estado: EstadoProceso.enPausa,
    gradiente: _g4,
    sesionesCompletadas: 3,
    proximaCita: null,
    nivelBienestar: 55,
    ultimoEstado: '😮‍💨 Cansado',
    telefono: '+57 301 556 1209',
    email: 'mateo.h@email.com',
  ),
  PacienteDemo(
    id: 'p5',
    nombre: 'Camila Torres',
    iniciales: 'CT',
    edad: 31,
    motivoConsulta: 'Autoestima y regulación emocional',
    estado: EstadoProceso.activo,
    gradiente: _g5,
    sesionesCompletadas: 6,
    proximaCita: 'Jue, 2:00 PM',
    nivelBienestar: 60,
    ultimoEstado: '😌 Tranquila',
    telefono: '+57 318 774 4456',
    email: 'camila.torres@email.com',
  ),
  PacienteDemo(
    id: 'p6',
    nombre: 'Juan David Marín',
    iniciales: 'JM',
    edad: 27,
    motivoConsulta: 'Evaluación inicial - ansiedad',
    estado: EstadoProceso.nuevo,
    gradiente: _g6,
    sesionesCompletadas: 0,
    proximaCita: 'Vie, 6:00 PM',
    nivelBienestar: 42,
    ultimoEstado: '😰 Ansioso',
    telefono: '+57 312 330 9981',
    email: 'jd.marin@email.com',
  ),
];

// ── Citas de ejemplo ─────────────────────────────────────────────────────────

final List<CitaDemo> citasDemo = () {
  final hoy = DateTime.now();
  DateTime d(int addDays) => DateTime(hoy.year, hoy.month, hoy.day + addDays);
  return <CitaDemo>[
    CitaDemo(
      id: 'c1', pacienteId: 'p1', pacienteNombre: 'Valentina Restrepo',
      pacienteIniciales: 'VR', gradiente: _g1, fecha: d(0), hora: '9:30 AM',
      estado: EstadoCita.agendada, modalidad: 'Videollamada',
      motivo: 'Seguimiento - manejo de ansiedad',
    ),
    CitaDemo(
      id: 'c2', pacienteId: 'p2', pacienteNombre: 'Andrés Felipe Gómez',
      pacienteIniciales: 'AG', gradiente: _g2, fecha: d(0), hora: '11:00 AM',
      estado: EstadoCita.agendada, modalidad: 'Videollamada',
      motivo: 'Proceso de duelo - sesión 6',
    ),
    CitaDemo(
      id: 'c3', pacienteId: 'p5', pacienteNombre: 'Camila Torres',
      pacienteIniciales: 'CT', gradiente: _g5, fecha: d(0), hora: '3:00 PM',
      estado: EstadoCita.agendada, modalidad: 'Presencial',
      motivo: 'Trabajo en autoestima',
    ),
    CitaDemo(
      id: 'c4', pacienteId: 'p3', pacienteNombre: 'Daniela Ospina',
      pacienteIniciales: 'DO', gradiente: _g3, fecha: d(1), hora: '4:30 PM',
      estado: EstadoCita.agendada, modalidad: 'Videollamada',
      motivo: 'Exposición gradual - fobia social',
    ),
    CitaDemo(
      id: 'c5', pacienteId: 'p6', pacienteNombre: 'Juan David Marín',
      pacienteIniciales: 'JM', gradiente: _g6, fecha: d(3), hora: '6:00 PM',
      estado: EstadoCita.agendada, modalidad: 'Videollamada',
      motivo: 'Primera sesión - evaluación inicial',
    ),
    CitaDemo(
      id: 'c6', pacienteId: 'p1', pacienteNombre: 'Valentina Restrepo',
      pacienteIniciales: 'VR', gradiente: _g1, fecha: d(-2), hora: '9:30 AM',
      estado: EstadoCita.completada, modalidad: 'Videollamada',
      motivo: 'Seguimiento - técnicas de respiración',
    ),
    CitaDemo(
      id: 'c7', pacienteId: 'p4', pacienteNombre: 'Mateo Hernández',
      pacienteIniciales: 'MH', gradiente: _g4, fecha: d(-3), hora: '5:00 PM',
      estado: EstadoCita.cancelada, modalidad: 'Presencial',
      motivo: 'Cancelada por el paciente',
    ),
    CitaDemo(
      id: 'c8', pacienteId: 'p3', pacienteNombre: 'Daniela Ospina',
      pacienteIniciales: 'DO', gradiente: _g3, fecha: d(-5), hora: '4:30 PM',
      estado: EstadoCita.completada, modalidad: 'Videollamada',
      motivo: 'Manejo de crisis de pánico',
    ),
  ];
}();

// ── Tareas de ejemplo ────────────────────────────────────────────────────────

const tareasDemo = <TareaDemo>[
  TareaDemo(
    id: 't1', pacienteNombre: 'Valentina Restrepo',
    titulo: 'Registro de pensamientos automáticos', tipo: 'Registro',
    completada: true, fechaLimite: 'Vence hoy',
  ),
  TareaDemo(
    id: 't2', pacienteNombre: 'Andrés Felipe Gómez',
    titulo: 'Diario emocional diario', tipo: 'Diario',
    completada: false, fechaLimite: 'Vence en 2 días',
  ),
  TareaDemo(
    id: 't3', pacienteNombre: 'Daniela Ospina',
    titulo: 'Ejercicio de exposición gradual', tipo: 'Exposición',
    completada: true, fechaLimite: 'Completada ayer',
  ),
  TareaDemo(
    id: 't4', pacienteNombre: 'Camila Torres',
    titulo: 'Lista de gratitud (7 días)', tipo: 'Gratitud',
    completada: false, fechaLimite: 'Vence en 4 días',
  ),
];

// ── Biblioteca de tareas frecuentes ──────────────────────────────────────────

const bibliotecaTareas = <(IconData, String, String)>[
  (Icons.edit_note_rounded, 'Diario emocional', 'Registro diario de emociones'),
  (Icons.psychology_rounded, 'Registro de pensamientos', 'Identificar pensamientos automáticos'),
  (Icons.air_rounded, 'Ejercicios de respiración', 'Técnicas de respiración diafragmática'),
  (Icons.directions_run_rounded, 'Activación conductual', 'Programación de actividades'),
  (Icons.favorite_rounded, 'Lista de gratitud', 'Registro de agradecimientos'),
  (Icons.lightbulb_rounded, 'Pensamientos automáticos', 'Identificación y reestructuración'),
  (Icons.bedtime_rounded, 'Seguimiento del sueño', 'Registro de hábitos de sueño'),
  (Icons.trending_up_rounded, 'Exposición gradual', 'Jerarquía de exposición a miedos'),
];

// ── Biblioteca de recursos por categoría ─────────────────────────────────────

const categoriasRecursos = <(IconData, String, int, Color)>[
  (Icons.bolt_rounded, 'Ansiedad', 12, Color(0xFF6B4EFF)),
  (Icons.whatshot_rounded, 'Estrés', 8, Color(0xFFD97706)),
  (Icons.bedtime_rounded, 'Sueño', 6, Color(0xFF4338CA)),
  (Icons.self_improvement, 'Autoestima', 9, Color(0xFFBE185D)),
  (Icons.balance_rounded, 'Regulación emocional', 11, Color(0xFF059669)),
  (Icons.spa_rounded, 'Duelo', 5, Color(0xFF6B7280)),
  (Icons.people_rounded, 'Relaciones', 7, Color(0xFF0891B2)),
  (Icons.checklist_rounded, 'Hábitos', 10, Color(0xFF7C3AED)),
];

// ── Alertas de ejemplo ───────────────────────────────────────────────────────

const alertasDemo = <AlertaDemo>[
  AlertaDemo(
    texto: 'No completó su tarea asignada',
    paciente: 'Andrés Felipe Gómez',
    icono: Icons.assignment_late_rounded,
    color: Color(0xFFD97706),
  ),
  AlertaDemo(
    texto: 'Registró bajo estado emocional',
    paciente: 'Juan David Marín',
    icono: Icons.sentiment_dissatisfied_rounded,
    color: Color(0xFFDC2626),
  ),
  AlertaDemo(
    texto: 'Sin próxima cita agendada',
    paciente: 'Mateo Hernández',
    icono: Icons.event_busy_rounded,
    color: Color(0xFF6B7280),
  ),
  AlertaDemo(
    texto: 'Historia clínica incompleta',
    paciente: 'Juan David Marín',
    icono: Icons.folder_off_rounded,
    color: Color(0xFF6B4EFF),
  ),
];
