import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATOS DE EJEMPLO para el panel SuperAdmin.
//
// IMPORTANTE: aquí SOLO hay datos administrativos y métricas AGREGADAS/ANÓNIMAS.
// Ninguna entidad clínica sensible (historia, diario, notas) se importa ni se
// carga en este archivo. Privacidad por diseño.
// ─────────────────────────────────────────────────────────────────────────────

// ── Métricas globales del dashboard ──────────────────────────────────────────

class MetricaGlobal {
  final IconData icono;
  final String label;
  final String valor;
  final String detalle;
  final Color color;
  const MetricaGlobal(this.icono, this.label, this.valor, this.detalle, this.color);
}

const metricasGlobales = <MetricaGlobal>[
  MetricaGlobal(Icons.medical_services_rounded, 'Psicólogos', '24',
      '21 activos · 3 inactivos', Color(0xFF6B4EFF)),
  MetricaGlobal(Icons.people_alt_rounded, 'Pacientes', '348',
      '+18 esta semana', Color(0xFF059669)),
  MetricaGlobal(Icons.event_note_rounded, 'Citas (mes)', '1.204',
      '86 hoy', Color(0xFF0891B2)),
  MetricaGlobal(Icons.apartment_rounded, 'Clínicas', '5',
      '4 activas', Color(0xFF7C3AED)),
  MetricaGlobal(Icons.trending_up_rounded, 'Usuarios activos', '289',
      '83% del total', Color(0xFFD97706)),
  MetricaGlobal(Icons.payments_rounded, 'Ingresos (mes)', '\$8.4M',
      '+12% vs anterior', Color(0xFFBE185D)),
];

// ── Uso de plataforma (barras semanales, dato agregado) ──────────────────────

const usoSemanal = <(String, double)>[
  ('L', 0.55), ('M', 0.72), ('X', 0.61), ('J', 0.88),
  ('V', 0.79), ('S', 0.40), ('D', 0.30),
];

// ── Recursos más usados (agregado, sin paciente identificable) ───────────────

const recursosMasUsados = <(String, int)>[
  ('Respiración diafragmática (audio)', 412),
  ('Guía: manejo de ansiedad (PDF)', 388),
  ('Meditación para dormir (audio)', 301),
  ('Registro de pensamientos (plantilla)', 276),
  ('Mindfulness 10 min (video)', 245),
];

// ── Métricas de bienestar ANÓNIMAS y AGREGADAS ───────────────────────────────
// Nunca nombres, diagnósticos ni datos clínicos identificables.

const bienestarAgregado = <(String, int, Color)>[
  ('Bienestar alto (65-100%)', 41, Color(0xFF059669)),
  ('Bienestar medio (50-64%)', 38, Color(0xFFD97706)),
  ('Bienestar bajo (0-49%)', 21, Color(0xFFDC2626)),
];

// ── Alertas técnicas / administrativas ───────────────────────────────────────

class AlertaAdmin {
  final IconData icono;
  final String texto;
  final String detalle;
  final Color color;
  const AlertaAdmin(this.icono, this.texto, this.detalle, this.color);
}

const alertasAdmin = <AlertaAdmin>[
  AlertaAdmin(Icons.key_rounded, 'Solicitud de acceso pendiente',
      '1 esperando aprobación', Color(0xFFD97706)),
  AlertaAdmin(Icons.support_agent_rounded, 'Tickets de soporte abiertos',
      '3 sin asignar', Color(0xFF6B4EFF)),
  AlertaAdmin(Icons.credit_card_off_rounded, 'Pagos pendientes',
      '2 suscripciones por vencer', Color(0xFFDC2626)),
  AlertaAdmin(Icons.cloud_done_rounded, 'Sistema operativo',
      'Sin incidencias técnicas', Color(0xFF059669)),
];

// ── Psicólogos (datos ADMINISTRATIVOS, sin notas clínicas) ───────────────────

class PsicologoAdmin {
  final String id;
  final String nombre;
  final String iniciales;
  final String email;
  final String clinica;
  final bool activo;
  final int numPacientes; // solo el número
  final int numCitas;     // solo el número
  final String plan;
  final String registro;
  final String ultimoAcceso;
  final List<Color> gradiente;

  const PsicologoAdmin({
    required this.id,
    required this.nombre,
    required this.iniciales,
    required this.email,
    required this.clinica,
    required this.activo,
    required this.numPacientes,
    required this.numCitas,
    required this.plan,
    required this.registro,
    required this.ultimoAcceso,
    required this.gradiente,
  });
}

const psicologosAdmin = <PsicologoAdmin>[
  PsicologoAdmin(
    id: 'ps1', nombre: 'Dra. María González', iniciales: 'MG',
    email: 'dra.gonzalez@calmaia.com', clinica: 'Centro Calma Bogotá',
    activo: true, numPacientes: 18, numCitas: 142, plan: 'Profesional',
    registro: '12 ene 2026', ultimoAcceso: 'Hace 2 horas',
    gradiente: [Color(0xFF5B21B6), Color(0xFF7C3AED)],
  ),
  PsicologoAdmin(
    id: 'ps2', nombre: 'Dr. Carlos Mendoza', iniciales: 'CM',
    email: 'dr.mendoza@calmaia.com', clinica: 'Centro Calma Bogotá',
    activo: true, numPacientes: 23, numCitas: 198, plan: 'Profesional',
    registro: '03 feb 2026', ultimoAcceso: 'Hace 1 día',
    gradiente: [Color(0xFF0891B2), Color(0xFF06B6D4)],
  ),
  PsicologoAdmin(
    id: 'ps3', nombre: 'Dra. Laura Sánchez', iniciales: 'LS',
    email: 'dra.sanchez@calmaia.com', clinica: 'Calma Medellín',
    activo: true, numPacientes: 31, numCitas: 256, plan: 'Premium',
    registro: '20 nov 2025', ultimoAcceso: 'Hace 5 horas',
    gradiente: [Color(0xFFBE185D), Color(0xFFEC4899)],
  ),
  PsicologoAdmin(
    id: 'ps4', nombre: 'Dr. Andrés Torres', iniciales: 'AT',
    email: 'dr.torres@calmaia.com', clinica: 'Independiente',
    activo: false, numPacientes: 9, numCitas: 67, plan: 'Básico',
    registro: '15 mar 2026', ultimoAcceso: 'Hace 21 días',
    gradiente: [Color(0xFF065F46), Color(0xFF059669)],
  ),
];

// ── Pacientes (vista ADMINISTRATIVA, datos NO clínicos) ──────────────────────

class PacienteAdmin {
  final String id;
  final String ref;          // referencia anonimizada
  final String nombre;       // dato básico de cuenta
  final String iniciales;
  final String psicologo;
  final bool activo;
  final bool tieneConsentimiento;
  final bool tieneCitasActivas;
  final String registro;
  final List<Color> gradiente;

  const PacienteAdmin({
    required this.id,
    required this.ref,
    required this.nombre,
    required this.iniciales,
    required this.psicologo,
    required this.activo,
    required this.tieneConsentimiento,
    required this.tieneCitasActivas,
    required this.registro,
    required this.gradiente,
  });
}

const pacientesAdmin = <PacienteAdmin>[
  PacienteAdmin(
    id: 'p1', ref: 'PAC-00318', nombre: 'Valentina R.', iniciales: 'VR',
    psicologo: 'Dra. María González', activo: true,
    tieneConsentimiento: true, tieneCitasActivas: true,
    registro: '18 mar 2026', gradiente: [Color(0xFF5B21B6), Color(0xFF7C3AED)],
  ),
  PacienteAdmin(
    id: 'p2', ref: 'PAC-00412', nombre: 'Andrés G.', iniciales: 'AG',
    psicologo: 'Dr. Carlos Mendoza', activo: true,
    tieneConsentimiento: true, tieneCitasActivas: true,
    registro: '02 abr 2026', gradiente: [Color(0xFF0891B2), Color(0xFF06B6D4)],
  ),
  PacienteAdmin(
    id: 'p3', ref: 'PAC-00455', nombre: 'Daniela O.', iniciales: 'DO',
    psicologo: 'Dra. Laura Sánchez', activo: true,
    tieneConsentimiento: true, tieneCitasActivas: true,
    registro: '11 feb 2026', gradiente: [Color(0xFFBE185D), Color(0xFFEC4899)],
  ),
  PacienteAdmin(
    id: 'p4', ref: 'PAC-00501', nombre: 'Mateo H.', iniciales: 'MH',
    psicologo: 'Dra. María González', activo: false,
    tieneConsentimiento: false, tieneCitasActivas: false,
    registro: '28 abr 2026', gradiente: [Color(0xFF065F46), Color(0xFF059669)],
  ),
  PacienteAdmin(
    id: 'p5', ref: 'PAC-00533', nombre: 'Juan David M.', iniciales: 'JM',
    psicologo: 'Dr. Carlos Mendoza', activo: true,
    tieneConsentimiento: false, tieneCitasActivas: true,
    registro: '05 may 2026', gradiente: [Color(0xFF4338CA), Color(0xFF6366F1)],
  ),
];
