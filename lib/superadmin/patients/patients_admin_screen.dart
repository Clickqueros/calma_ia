import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import '../../core/roles/user_role.dart';
import '../../core/access/clinical_data_guard.dart';
import '../data/superadmin_demo_data.dart';
import '../widgets/status_badge.dart';

class PatientsAdminScreen extends StatelessWidget {
  const PatientsAdminScreen({super.key});

  bool _small(BuildContext c) => MediaQuery.of(c).size.width < 900;

  @override
  Widget build(BuildContext context) {
    final small = _small(context);
    final pad = small ? 18.0 : 32.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bannerPrivacidad(),
          const SizedBox(height: 20),
          ...pacientesAdmin.map((p) => _pacienteCard(context, p, small)),
        ],
      ),
    );
  }

  Widget _bannerPrivacidad() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EEFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8CFFF)),
      ),
      child: const Row(
        children: [
          Icon(Icons.privacy_tip_rounded, color: PlatTheme.purple, size: 19),
          SizedBox(width: 11),
          Expanded(
            child: Text(
                'Vista administrativa. Solo datos de cuenta. La información clínica '
                '(historia, diario, evolución) está protegida y requiere autorización.',
                style: TextStyle(
                    color: Color(0xFF4C1D95), fontSize: 12.5, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _pacienteCard(BuildContext context, PacienteAdmin p, bool small) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFECFF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: p.gradiente),
                ),
                child: Center(
                  child: Text(p.iniciales,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(p.nombre,
                            style: const TextStyle(
                                color: PlatTheme.textDark,
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        StatusBadge(p.activo
                            ? BadgeStatus.activo
                            : BadgeStatus.inactivo),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('${p.ref} · ${p.psicologo}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: PlatTheme.textGray, fontSize: 12.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFFF2F0FF)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 18,
            runSpacing: 10,
            children: [
              _flag(p.tieneConsentimiento, 'Consentimiento'),
              _flag(p.tieneCitasActivas, 'Citas activas'),
              _dato(Icons.calendar_today_rounded, 'Registro: ${p.registro}'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _accion(context, p.activo ? 'Desactivar' : 'Activar',
                  Icons.toggle_on_rounded),
              const SizedBox(width: 8),
              _accion(context, 'Soporte', Icons.support_agent_rounded),
              const Spacer(),
              // ← ACCIÓN CLAVE: intentar ver historia clínica dispara el bloqueo
              _accionClinica(context, p),
            ],
          ),
        ],
      ),
    );
  }

  /// Botón que intenta abrir información clínica → ClinicalDataGuard la bloquea.
  Widget _accionClinica(BuildContext context, PacienteAdmin p) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ClinicalDataGuard(
            modulo: SensitiveModule.clinicalHistory,
            pacienteRef: p.ref,
            pacienteId: p.id,
            // Este builder SOLO se ejecuta si hay autorización vigente.
            builder: (_) => _historiaPlaceholder(p),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0xFFFCD9A8)),
          color: const Color(0xFFFFF7ED),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_rounded, size: 14, color: Color(0xFFD97706)),
            SizedBox(width: 6),
            Text('Ver historia clínica',
                style: TextStyle(
                    color: Color(0xFFD97706),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // Solo se ve si hay AccessGrant vigente (en el demo: tras aprobar la solicitud).
  Widget _historiaPlaceholder(PacienteAdmin p) {
    return Scaffold(
      backgroundColor: PlatTheme.softBg,
      appBar: AppBar(
        backgroundColor: PlatTheme.darkNavy,
        title: Text('Historia clínica · ${p.ref}',
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
              'Acceso autorizado temporalmente. Este contenido se mostraría aquí '
              'bajo el AccessGrant vigente. Todo acceso queda registrado en auditoría.',
              textAlign: TextAlign.center,
              style: TextStyle(color: PlatTheme.textGray, fontSize: 14, height: 1.5)),
        ),
      ),
    );
  }

  Widget _flag(bool ok, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 15,
            color: ok ? const Color(0xFF059669) : const Color(0xFFDC2626)),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(color: PlatTheme.textGray, fontSize: 12.5)),
      ],
    );
  }

  Widget _dato(IconData icon, String txt) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: PlatTheme.textGray),
        const SizedBox(width: 5),
        Text(txt,
            style: const TextStyle(color: PlatTheme.textGray, fontSize: 12.5)),
      ],
    );
  }

  Widget _accion(BuildContext context, String label, IconData icon) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$label (demo)'),
        backgroundColor: PlatTheme.darkNavy,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      )),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0xFFE8E4FF)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: PlatTheme.textGray),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: PlatTheme.textGray,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
