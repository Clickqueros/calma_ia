import 'package:flutter/material.dart';
import '../roles/user_role.dart';
import '../roles/access_control.dart';
import '../../superadmin/restricted/access_restricted_screen.dart';

/// Envuelve cualquier contenido clínico sensible.
/// Si el rol actual NO tiene acceso vigente, muestra la pantalla
/// "Acceso restringido" en lugar del contenido. Registra el intento.
///
/// Uso:
///   ClinicalDataGuard(
///     modulo: SensitiveModule.clinicalHistory,
///     pacienteRef: 'PAC-00412',
///     pacienteId: 'p1',
///     builder: (ctx) => HistoriaClinicaWidget(...),
///   )
class ClinicalDataGuard extends StatelessWidget {
  final SensitiveModule modulo;
  final String pacienteRef;
  final String pacienteId;
  final WidgetBuilder builder;

  const ClinicalDataGuard({
    super.key,
    required this.modulo,
    required this.pacienteRef,
    required this.builder,
    this.pacienteId = '',
  });

  @override
  Widget build(BuildContext context) {
    final permitido = AccessControl.instance
        .checkAndAudit(modulo, pacienteRef, pacienteId: pacienteId);
    if (permitido) return builder(context);
    return AccessRestrictedScreen(
      modulo: modulo,
      pacienteRef: pacienteRef,
      pacienteId: pacienteId,
    );
  }
}
