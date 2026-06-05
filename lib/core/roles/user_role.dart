// ─────────────────────────────────────────────────────────────────────────────
// Roles del sistema. Preparado para auth real; hoy se usa en modo mock.
// ─────────────────────────────────────────────────────────────────────────────

enum UserRole {
  superAdmin('Super Administrador'),
  psychologist('Psicólogo'),
  patient('Paciente'),
  clinicAdmin('Administrador de Clínica'), // preparado, sin pantallas aún
  supportAgent('Agente de Soporte');       // preparado, sin pantallas aún

  final String label;
  const UserRole(this.label);
}

// ── Módulos clínicos SENSIBLES ───────────────────────────────────────────────
// El SuperAdmin NO accede a estos directamente (principio de mínimo privilegio).
// Solo con un AccessGrant vigente concedido por el psicólogo o el paciente.

enum SensitiveModule {
  clinicalHistory('Historia clínica'),
  sessionNotes('Notas de sesión'),
  taskResponses('Respuestas de tareas'),
  journal('Diario personal'),
  privateAttachments('Adjuntos privados'),
  clinicalDocuments('Documentos clínicos'),
  therapeuticEvolution('Evolución terapéutica');

  final String label;
  const SensitiveModule(this.label);
}
