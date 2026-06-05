import 'package:flutter/foundation.dart';
import 'models/access_request.dart';
import 'models/access_grant.dart';
import '../roles/user_role.dart';

/// Gestiona las solicitudes (AccessRequest) y autorizaciones (AccessGrant)
/// de acceso excepcional a datos clínicos. Mock, listo para backend.
class AccessService extends ChangeNotifier {
  AccessService._() {
    _seed();
  }
  static final instance = AccessService._();

  final List<AccessRequest> _requests = [];
  final List<AccessGrant> _grants = [];

  List<AccessRequest> get requests => List.unmodifiable(_requests.reversed);
  List<AccessGrant> get grants => List.unmodifiable(_grants.reversed);

  List<AccessRequest> get pendientes =>
      _requests.where((r) => r.estado == AccessRequestStatus.pendiente).toList();

  int _c = 0;

  // ── Crear solicitud (SuperAdmin) ───────────────────────────────────────────
  AccessRequest solicitar({
    required String solicitanteId,
    required String solicitanteNombre,
    required String pacienteId,
    required String pacienteRef,
    required List<SensitiveModule> modulos,
    required String motivo,
  }) {
    final req = AccessRequest(
      id: 'req_${_c++}',
      solicitanteId: solicitanteId,
      solicitanteNombre: solicitanteNombre,
      pacienteId: pacienteId,
      pacienteRef: pacienteRef,
      modulos: modulos,
      motivo: motivo,
      estado: AccessRequestStatus.pendiente,
      fecha: DateTime.now(),
    );
    _requests.add(req);
    notifyListeners();
    return req;
  }

  // ── Aprobar (psicólogo/paciente) → genera AccessGrant ──────────────────────
  AccessGrant aprobar(
    String requestId, {
    required Duration duracion,
    required String aprobadoPor,
  }) {
    final i = _requests.indexWhere((r) => r.id == requestId);
    final req = _requests[i];
    _requests[i] = req.copyWith(estado: AccessRequestStatus.aprobada);

    final grant = AccessGrant(
      id: 'grant_${_c++}',
      requestId: req.id,
      usuarioAutorizadoId: req.solicitanteId,
      pacienteId: req.pacienteId,
      modulos: req.modulos,
      inicio: DateTime.now(),
      expiracion: DateTime.now().add(duracion),
      motivo: req.motivo,
      aprobadoPor: aprobadoPor,
      estado: AccessGrantStatus.activo,
    );
    _grants.add(grant);
    notifyListeners();
    return grant;
  }

  void rechazar(String requestId) {
    final i = _requests.indexWhere((r) => r.id == requestId);
    _requests[i] = _requests[i].copyWith(estado: AccessRequestStatus.rechazada);
    notifyListeners();
  }

  void revocar(String grantId) {
    final i = _grants.indexWhere((g) => g.id == grantId);
    final g = _grants[i];
    _grants[i] = AccessGrant(
      id: g.id, requestId: g.requestId,
      usuarioAutorizadoId: g.usuarioAutorizadoId, pacienteId: g.pacienteId,
      modulos: g.modulos, inicio: g.inicio, expiracion: g.expiracion,
      motivo: g.motivo, aprobadoPor: g.aprobadoPor,
      estado: AccessGrantStatus.revocado, registroUso: g.registroUso,
    );
    notifyListeners();
  }

  /// ¿Existe un grant vigente que cubra este módulo para este paciente?
  bool tieneAccesoVigente(SensitiveModule m, String pacienteId) =>
      _grants.any((g) => g.cubre(m, pacienteId));

  void _seed() {
    // Una solicitud pendiente de ejemplo para mostrar el módulo.
    _requests.add(AccessRequest(
      id: 'req_${_c++}',
      solicitanteId: 'admin',
      solicitanteNombre: 'Eddier (SuperAdmin)',
      pacienteId: 'p1',
      pacienteRef: 'PAC-00318',
      modulos: const [SensitiveModule.clinicalHistory],
      motivo: 'El paciente reportó un error y solicitó revisión de su expediente.',
      estado: AccessRequestStatus.pendiente,
      fecha: DateTime.now().subtract(const Duration(hours: 4)),
    ));
  }
}
