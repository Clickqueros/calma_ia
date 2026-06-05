import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import '../../core/roles/user_role.dart';
import '../../core/roles/access_control.dart';
import '../../core/access/access_service.dart';
import '../../core/audit/audit_service.dart';
import '../../core/audit/audit_log.dart';

/// Formulario para crear una solicitud de acceso excepcional (AccessRequest).
class SolicitarAccesoSheet extends StatefulWidget {
  final SensitiveModule modulo;
  final String pacienteRef;
  final String pacienteId;

  const SolicitarAccesoSheet({
    super.key,
    required this.modulo,
    required this.pacienteRef,
    required this.pacienteId,
  });

  @override
  State<SolicitarAccesoSheet> createState() => _SolicitarAccesoSheetState();
}

class _SolicitarAccesoSheetState extends State<SolicitarAccesoSheet> {
  final _ctrl = TextEditingController();
  bool _enviado = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _enviar() {
    AccessService.instance.solicitar(
      solicitanteId: 'admin',
      solicitanteNombre: 'Eddier (SuperAdmin)',
      pacienteId: widget.pacienteId,
      pacienteRef: widget.pacienteRef,
      modulos: [widget.modulo],
      motivo: _ctrl.text.trim().isEmpty
          ? 'Sin motivo especificado'
          : _ctrl.text.trim(),
    );
    AuditService.instance.registrar(
      usuario: AccessControl.instance.currentUserEmail,
      accion: 'Solicitud de acceso especial',
      recurso: 'AccessRequest',
      resultado: AuditResult.info,
      pacienteRef: widget.pacienteRef,
      motivo: _ctrl.text.trim(),
    );
    setState(() => _enviado = true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          22, 18, 22, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: _enviado ? _confirmacion() : _formulario(),
    );
  }

  Widget _formulario() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: const Color(0xFFE8E4FF),
                borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Solicitar acceso excepcional',
            style: TextStyle(
                color: PlatTheme.textDark,
                fontSize: 19,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          'Tu solicitud se enviará al profesional tratante y/o al paciente para '
          'su aprobación. Quedará registrada en la auditoría.',
          style: const TextStyle(
              color: PlatTheme.textGray, fontSize: 13.5, height: 1.5),
        ),
        const SizedBox(height: 18),
        _infoRow(Icons.folder_outlined, 'Información', widget.modulo.label),
        const SizedBox(height: 8),
        _infoRow(Icons.person_outline_rounded, 'Paciente', widget.pacienteRef),
        const SizedBox(height: 18),
        const Text('Motivo de la solicitud',
            style: TextStyle(
                color: PlatTheme.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _ctrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Ej: El paciente reportó un error y solicitó revisión...',
            hintStyle:
                const TextStyle(color: PlatTheme.textGray, fontSize: 13),
            filled: true,
            fillColor: PlatTheme.softBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8E4FF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8E4FF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: PlatTheme.purple),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _enviar,
            style: ElevatedButton.styleFrom(
              backgroundColor: PlatTheme.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Enviar solicitud',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _confirmacion() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE8FAF0),
          ),
          child: const Icon(Icons.check_rounded,
              color: Color(0xFF059669), size: 34),
        ),
        const SizedBox(height: 18),
        const Text('Solicitud enviada',
            style: TextStyle(
                color: PlatTheme.textDark,
                fontSize: 19,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'El profesional tratante recibirá tu solicitud. Cuando sea aprobada, '
            'tendrás acceso temporal y acotado. Puedes ver el estado en '
            '"Solicitudes de acceso".',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: PlatTheme.textGray, fontSize: 13.5, height: 1.5),
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: PlatTheme.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Entendido',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String valor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PlatTheme.softBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: PlatTheme.purple),
          const SizedBox(width: 10),
          Text('$label:',
              style: const TextStyle(color: PlatTheme.textGray, fontSize: 13)),
          const Spacer(),
          Flexible(
            child: Text(valor,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: PlatTheme.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
