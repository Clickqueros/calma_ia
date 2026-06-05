import 'package:flutter/foundation.dart';
import 'audit_log.dart';

/// Servicio de auditoría (mock). Misma interfaz que tendrá con backend,
/// para que conectar Supabase después sea enchufar, no reescribir.
class AuditService extends ChangeNotifier {
  AuditService._() {
    _seed();
  }
  static final instance = AuditService._();

  final List<AuditLog> _logs = [];
  List<AuditLog> get logs => List.unmodifiable(_logs.reversed);

  int _counter = 0;

  void registrar({
    required String usuario,
    required String accion,
    required String recurso,
    required AuditResult resultado,
    String? pacienteRef,
    String? motivo,
  }) {
    _logs.add(AuditLog(
      id: 'log_${_counter++}',
      usuario: usuario,
      accion: accion,
      recurso: recurso,
      resultado: resultado,
      fecha: DateTime.now(),
      pacienteRef: pacienteRef,
      motivo: motivo,
    ));
    notifyListeners();
  }

  // ── Datos de ejemplo para mostrar el módulo de auditoría ───────────────────
  void _seed() {
    final now = DateTime.now();
    final seed = <AuditLog>[
      AuditLog(
        id: 'log_${_counter++}',
        usuario: 'admin@calmaia.com',
        accion: 'Inicio de sesión',
        recurso: 'Auth',
        resultado: AuditResult.permitido,
        fecha: now.subtract(const Duration(minutes: 12)),
      ),
      AuditLog(
        id: 'log_${_counter++}',
        usuario: 'admin@calmaia.com',
        accion: 'Intento de acceso a historia clínica',
        recurso: 'ClinicalHistory',
        resultado: AuditResult.denegado,
        fecha: now.subtract(const Duration(hours: 2)),
        pacienteRef: 'PAC-00412',
        motivo: 'No autorizado',
      ),
      AuditLog(
        id: 'log_${_counter++}',
        usuario: 'admin@calmaia.com',
        accion: 'Creación de usuario psicólogo',
        recurso: 'User',
        resultado: AuditResult.permitido,
        fecha: now.subtract(const Duration(hours: 5)),
      ),
      AuditLog(
        id: 'log_${_counter++}',
        usuario: 'dra.gonzalez@calmaia.com',
        accion: 'Cambio de contraseña',
        recurso: 'Auth',
        resultado: AuditResult.permitido,
        fecha: now.subtract(const Duration(days: 1)),
      ),
      AuditLog(
        id: 'log_${_counter++}',
        usuario: 'admin@calmaia.com',
        accion: 'Solicitud de acceso especial',
        recurso: 'AccessRequest',
        resultado: AuditResult.info,
        fecha: now.subtract(const Duration(days: 1, hours: 3)),
        pacienteRef: 'PAC-00318',
        motivo: 'Soporte técnico solicitado por el paciente',
      ),
    ];
    _logs.addAll(seed);
  }
}
