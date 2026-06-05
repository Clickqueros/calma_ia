import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import '../../core/audit/audit_service.dart';
import '../../core/audit/audit_log.dart';

class AuditScreen extends StatelessWidget {
  const AuditScreen({super.key});

  bool _small(BuildContext c) => MediaQuery.of(c).size.width < 900;

  Color _color(AuditResult r) => switch (r) {
        AuditResult.permitido => const Color(0xFF059669),
        AuditResult.denegado => const Color(0xFFDC2626),
        AuditResult.info => const Color(0xFF6B4EFF),
      };

  @override
  Widget build(BuildContext context) {
    final small = _small(context);
    final pad = small ? 18.0 : 32.0;

    return AnimatedBuilder(
      animation: AuditService.instance,
      builder: (context, _) {
        final logs = AuditService.instance.logs;
        return SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'Registro de actividad. Solo metadatos — nunca contenido clínico.',
                  style: TextStyle(color: PlatTheme.textGray, fontSize: 14)),
              const SizedBox(height: 20),
              ...logs.map((l) => _logRow(l, small)),
            ],
          ),
        );
      },
    );
  }

  Widget _logRow(AuditLog l, bool small) {
    final c = _color(l.resultado);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEFECFF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              l.resultado == AuditResult.denegado
                  ? Icons.block_rounded
                  : l.resultado == AuditResult.info
                      ? Icons.info_outline_rounded
                      : Icons.check_rounded,
              color: c,
              size: 19,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(l.accion,
                          style: const TextStyle(
                              color: PlatTheme.textDark,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: c.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(l.resultado.label,
                          style: TextStyle(
                              color: c,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(l.usuario,
                    style: const TextStyle(
                        color: PlatTheme.textGray, fontSize: 12)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 14,
                  runSpacing: 4,
                  children: [
                    _meta(Icons.schedule_rounded, _fecha(l.fecha)),
                    _meta(Icons.dns_rounded, l.recurso),
                    if (l.pacienteRef != null)
                      _meta(Icons.tag_rounded, l.pacienteRef!),
                    if (l.motivo != null && l.motivo!.isNotEmpty)
                      _meta(Icons.notes_rounded, l.motivo!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String txt) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: PlatTheme.textGray),
        const SizedBox(width: 4),
        Text(txt,
            style: const TextStyle(color: PlatTheme.textGray, fontSize: 11.5)),
      ],
    );
  }

  String _fecha(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day}/${d.month}/${d.year} $h:$m';
  }
}
