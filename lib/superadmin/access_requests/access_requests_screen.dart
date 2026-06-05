import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import '../../core/access/access_service.dart';
import '../../core/access/models/access_request.dart';
import '../../core/access/models/access_grant.dart';
import '../../core/audit/audit_service.dart';
import '../../core/audit/audit_log.dart';
import '../widgets/status_badge.dart';

class AccessRequestsScreen extends StatelessWidget {
  const AccessRequestsScreen({super.key});

  bool _small(BuildContext c) => MediaQuery.of(c).size.width < 900;

  @override
  Widget build(BuildContext context) {
    final small = _small(context);
    final pad = small ? 18.0 : 32.0;

    return AnimatedBuilder(
      animation: AccessService.instance,
      builder: (context, _) {
        final requests = AccessService.instance.requests;
        final grants = AccessService.instance.grants;
        return SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _banner(),
              const SizedBox(height: 22),
              const Text('Solicitudes',
                  style: TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (requests.isEmpty)
                const EmptyState(
                    icono: Icons.key_off_rounded,
                    titulo: 'Sin solicitudes',
                    subtitulo: 'Las solicitudes de acceso aparecerán aquí.')
              else
                ...requests.map((r) => _requestCard(context, r)),
              if (grants.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text('Autorizaciones activas',
                    style: TextStyle(
                        color: PlatTheme.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...grants.map((g) => _grantCard(context, g)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _banner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PlatTheme.darkNavy, Color(0xFF2D1B69)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user_rounded, color: Color(0xFFFBBF24), size: 24),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Acceso excepcional a datos clínicos',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                    'Toda autorización es temporal, acotada y queda registrada en auditoría.',
                    style:
                        TextStyle(color: PlatTheme.softBlue, fontSize: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BadgeStatus _badge(AccessRequestStatus s) => switch (s) {
        AccessRequestStatus.pendiente => BadgeStatus.pendiente,
        AccessRequestStatus.aprobada => BadgeStatus.activo,
        AccessRequestStatus.rechazada => BadgeStatus.bloqueado,
        AccessRequestStatus.expirada => BadgeStatus.inactivo,
        AccessRequestStatus.revocada => BadgeStatus.bloqueado,
      };

  Widget _requestCard(BuildContext context, AccessRequest r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFECFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.key_rounded, color: PlatTheme.purple, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(r.modulos.map((m) => m.label).join(', '),
                    style: const TextStyle(
                        color: PlatTheme.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ),
              StatusBadge(_badge(r.estado), customLabel: r.estado.label),
            ],
          ),
          const SizedBox(height: 10),
          _row(Icons.person_outline_rounded, 'Solicitante', r.solicitanteNombre),
          _row(Icons.tag_rounded, 'Paciente', r.pacienteRef),
          _row(Icons.notes_rounded, 'Motivo', r.motivo),
          if (r.estado == AccessRequestStatus.pendiente) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 15, color: Color(0xFFD97706)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        'En producción decide el psicólogo o el paciente. Aquí puedes simular su respuesta:',
                        style: TextStyle(
                            color: Color(0xFF92400E), fontSize: 11.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _btn(context, 'Rechazar', false, () {
                    AccessService.instance.rechazar(r.id);
                    AuditService.instance.registrar(
                      usuario: 'dra.gonzalez@calmaia.com',
                      accion: 'Rechazó solicitud de acceso',
                      recurso: 'AccessRequest',
                      resultado: AuditResult.denegado,
                      pacienteRef: r.pacienteRef,
                    );
                  }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _btn(context, 'Aprobar (24h)', true, () {
                    AccessService.instance.aprobar(r.id,
                        duracion: const Duration(hours: 24),
                        aprobadoPor: 'Dra. María González');
                    AuditService.instance.registrar(
                      usuario: 'dra.gonzalez@calmaia.com',
                      accion: 'Aprobó acceso excepcional (24h)',
                      recurso: 'AccessGrant',
                      resultado: AuditResult.permitido,
                      pacienteRef: r.pacienteRef,
                    );
                    _toast(context,
                        'Acceso concedido por 24h. Ya puedes ver la historia de ${r.pacienteRef}.');
                  }),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _grantCard(BuildContext context, AccessGrant g) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8FAF0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA7E8C8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_open_rounded,
                  color: Color(0xFF059669), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Acceso vigente · ${g.pacienteId}',
                    style: const TextStyle(
                        color: Color(0xFF065F46),
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ),
              StatusBadge(
                  g.vigente ? BadgeStatus.activo : BadgeStatus.inactivo,
                  customLabel: g.vigente ? 'Vigente' : g.estado.label),
            ],
          ),
          const SizedBox(height: 8),
          Text('Módulos: ${g.modulos.map((m) => m.label).join(', ')}',
              style: const TextStyle(color: Color(0xFF065F46), fontSize: 12.5)),
          Text('Aprobado por: ${g.aprobadoPor}',
              style: const TextStyle(color: Color(0xFF065F46), fontSize: 12.5)),
          Text('Expira: ${_fecha(g.expiracion)}',
              style: const TextStyle(color: Color(0xFF065F46), fontSize: 12.5)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              AccessService.instance.revocar(g.id);
              AuditService.instance.registrar(
                usuario: 'dra.gonzalez@calmaia.com',
                accion: 'Revocó acceso antes del vencimiento',
                recurso: 'AccessGrant',
                resultado: AuditResult.info,
                pacienteRef: g.pacienteId,
              );
              _toast(context, 'Acceso revocado.');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: const Text('Revocar acceso',
                  style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: PlatTheme.textGray),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(color: PlatTheme.textGray, fontSize: 12.5)),
          Expanded(
            child: Text(valor,
                style: const TextStyle(
                    color: PlatTheme.textDark,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _btn(BuildContext context, String label, bool primary, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: primary ? PlatTheme.purple : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: primary ? PlatTheme.purple : const Color(0xFFE8E4FF)),
        ),
        child: Text(label,
            style: TextStyle(
                color: primary ? Colors.white : PlatTheme.textGray,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: PlatTheme.darkNavy,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ));
  }

  String _fecha(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day}/${d.month} $h:$m';
  }
}
