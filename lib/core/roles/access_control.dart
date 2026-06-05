import 'user_role.dart';
import '../access/access_service.dart';
import '../audit/audit_service.dart';
import '../audit/audit_log.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AccessControl — punto ÚNICO de decisión de permisos (mínimo privilegio).
//
// Toda pantalla que muestre datos sensibles DEBE preguntar aquí.
// No se duplica lógica de permisos en ninguna otra parte.
// ─────────────────────────────────────────────────────────────────────────────

class AccessControl {
  AccessControl._();
  static final instance = AccessControl._();

  // En el demo el rol activo es SuperAdmin. Con auth real esto vendrá de la sesión.
  UserRole currentRole = UserRole.superAdmin;
  String currentUserEmail = 'admin@calmaia.com';

  /// ¿El rol actual puede ver este módulo clínico para este paciente?
  ///
  /// SuperAdmin: SIEMPRE false, salvo que exista un AccessGrant vigente.
  /// Psychologist/Patient: gestionan su propio acceso (fuera de este panel).
  bool canViewClinical(SensitiveModule module, String pacienteId) {
    switch (currentRole) {
      case UserRole.superAdmin:
        return AccessService.instance.tieneAccesoVigente(module, pacienteId);
      case UserRole.psychologist:
      case UserRole.patient:
        return true; // su acceso se controla en sus propios paneles
      case UserRole.clinicAdmin:
      case UserRole.supportAgent:
        return false;
    }
  }

  /// Igual que canViewClinical pero además deja rastro en auditoría.
  /// Úsalo cuando el usuario intenta ABRIR el dato (no solo render pasivo).
  bool checkAndAudit(SensitiveModule module, String pacienteRef,
      {String pacienteId = ''}) {
    final permitido = canViewClinical(module, pacienteId.isEmpty ? pacienteRef : pacienteId);
    AuditService.instance.registrar(
      usuario: currentUserEmail,
      accion: 'Intento de acceso a ${module.label.toLowerCase()}',
      recurso: module.name,
      resultado: permitido ? AuditResult.permitido : AuditResult.denegado,
      pacienteRef: pacienteRef,
      motivo: permitido ? 'Autorización vigente' : 'No autorizado',
    );
    return permitido;
  }
}
