import '../../roles/user_role.dart';

enum AccessRequestStatus {
  pendiente('Pendiente'),
  aprobada('Aprobada'),
  rechazada('Rechazada'),
  expirada('Expirada'),
  revocada('Revocada');

  final String label;
  const AccessRequestStatus(this.label);
}

/// Solicitud de acceso excepcional a información clínica.
/// La crea el SuperAdmin; la aprueba/rechaza el psicólogo o el paciente.
class AccessRequest {
  final String id;
  final String solicitanteId;      // SuperAdmin que solicita
  final String solicitanteNombre;
  final String pacienteId;         // ID interno (no expone nombre clínico)
  final String pacienteRef;        // referencia parcialmente anonimizada
  final List<SensitiveModule> modulos;
  final String motivo;
  final AccessRequestStatus estado;
  final DateTime fecha;

  const AccessRequest({
    required this.id,
    required this.solicitanteId,
    required this.solicitanteNombre,
    required this.pacienteId,
    required this.pacienteRef,
    required this.modulos,
    required this.motivo,
    required this.estado,
    required this.fecha,
  });

  AccessRequest copyWith({AccessRequestStatus? estado}) => AccessRequest(
        id: id,
        solicitanteId: solicitanteId,
        solicitanteNombre: solicitanteNombre,
        pacienteId: pacienteId,
        pacienteRef: pacienteRef,
        modulos: modulos,
        motivo: motivo,
        estado: estado ?? this.estado,
        fecha: fecha,
      );
}
