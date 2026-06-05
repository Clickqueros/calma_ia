import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import '../../core/roles/user_role.dart';
import 'solicitar_acceso_sheet.dart';

/// Pantalla mostrada cuando el SuperAdmin intenta abrir información clínica.
/// Profesional, tranquilizadora: comunica que la plataforma protege al paciente.
class AccessRestrictedScreen extends StatelessWidget {
  final SensitiveModule modulo;
  final String pacienteRef;
  final String pacienteId;

  const AccessRestrictedScreen({
    super.key,
    required this.modulo,
    required this.pacienteRef,
    this.pacienteId = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlatTheme.darkNavy,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFD97706).withValues(alpha: 0.15),
                      border: Border.all(
                          color: const Color(0xFFD97706).withValues(alpha: 0.4),
                          width: 1.5),
                    ),
                    child: const Icon(Icons.lock_rounded,
                        color: Color(0xFFFBBF24), size: 40),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Acceso restringido',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Esta información corresponde a datos clínicos sensibles '
                    '(${modulo.label.toLowerCase()}). Tu rol de SuperAdmin no tiene '
                    'acceso directo a este contenido porque no eres el profesional '
                    'tratante.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: PlatTheme.softBlue, fontSize: 15, height: 1.6),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield_outlined,
                            color: PlatTheme.softBlue, size: 15),
                        const SizedBox(width: 8),
                        Text('Referencia: $pacienteRef',
                            style: const TextStyle(
                                color: PlatTheme.softBlue, fontSize: 12.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Acción primaria
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _solicitar(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PlatTheme.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.key_rounded, size: 18),
                      label: const Text('Solicitar acceso excepcional',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Volver al panel',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextButton.icon(
                    onPressed: () => _politica(context),
                    icon: const Icon(Icons.policy_outlined,
                        size: 15, color: PlatTheme.softBlue),
                    label: const Text('Ver política de privacidad',
                        style: TextStyle(
                            color: PlatTheme.softBlue, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _solicitar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SolicitarAccesoSheet(
        modulo: modulo,
        pacienteRef: pacienteRef,
        pacienteId: pacienteId.isEmpty ? pacienteRef : pacienteId,
      ),
    );
  }

  void _politica(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: PlatTheme.navyPurple,
        title: const Text('Política de privacidad clínica',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        content: const Text(
          'La información clínica de los pacientes es confidencial y está protegida. '
          'El rol SuperAdmin aplica el principio de mínimo privilegio: administra la '
          'plataforma sin acceso directo a historias clínicas, diagnósticos, notas, '
          'diario o respuestas sensibles.\n\n'
          'Cualquier acceso excepcional requiere autorización expresa del profesional '
          'tratante o del paciente, es temporal, acotado y queda registrado en la '
          'auditoría del sistema.',
          style: TextStyle(color: PlatTheme.softBlue, fontSize: 14, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido',
                style: TextStyle(color: PlatTheme.softPurple)),
          ),
        ],
      ),
    );
  }
}
