import '../../roles/user_role.dart';

enum AccessGrantStatus {
  activo('Activo'),
  expirado('Expirado'),
  revocado('Revocado');

  final String label;
  const AccessGrantStatus(this.label);
}

/// Autorización temporal y acotada para acceder a datos clínicos.
/// Se crea cuando una AccessRequest es aprobada.
class AccessGrant {
  final String id;
  final String requestId;
  final String usuarioAutorizadoId;   // SuperAdmin autorizado
  final String pacienteId;
  final List<SensitiveModule> modulos;
  final DateTime inicio;
  final DateTime expiracion;
  final String motivo;
  final String aprobadoPor;           // psicólogo o paciente
  final AccessGrantStatus estado;
  final List<DateTime> registroUso;   // cada consulta queda registrada

  const AccessGrant({
    required this.id,
    required this.requestId,
    required this.usuarioAutorizadoId,
    required this.pacienteId,
    required this.modulos,
    required this.inicio,
    required this.expiracion,
    required this.motivo,
    required this.aprobadoPor,
    required this.estado,
    this.registroUso = const [],
  });

  /// Vigente = activo Y dentro de la ventana temporal.
  bool get vigente =>
      estado == AccessGrantStatus.activo && DateTime.now().isBefore(expiracion);

  bool cubre(SensitiveModule m, String paciente) =>
      vigente && pacienteId == paciente && modulos.contains(m);
}
