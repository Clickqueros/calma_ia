enum AuditResult {
  permitido('Permitido'),
  denegado('Denegado'),
  info('Info');

  final String label;
  const AuditResult(this.label);
}

/// Registro de auditoría. Guarda METADATOS, nunca contenido clínico sensible.
class AuditLog {
  final String id;
  final String usuario;       // ej: admin@calmaia.com
  final String accion;        // ej: "Intento de acceso a historia clínica"
  final String recurso;       // ej: "ClinicalHistory"
  final AuditResult resultado;
  final DateTime fecha;
  final String? pacienteRef;  // ID interno o dato parcialmente anonimizado
  final String? motivo;

  const AuditLog({
    required this.id,
    required this.usuario,
    required this.accion,
    required this.recurso,
    required this.resultado,
    required this.fecha,
    this.pacienteRef,
    this.motivo,
  });
}
