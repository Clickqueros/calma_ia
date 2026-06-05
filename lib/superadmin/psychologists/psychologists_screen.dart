import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import '../data/superadmin_demo_data.dart';
import '../widgets/status_badge.dart';

class PsychologistsScreen extends StatelessWidget {
  const PsychologistsScreen({super.key});

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
          Row(
            children: [
              const Expanded(
                child: Text(
                    'Gestiona cuentas, estado y suscripción. No incluye notas clínicas.',
                    style: TextStyle(color: PlatTheme.textGray, fontSize: 14)),
              ),
              _btnNuevo(context, 'Nuevo psicólogo'),
            ],
          ),
          const SizedBox(height: 20),
          ...psicologosAdmin.map((p) => _psicologoCard(context, p, small)),
        ],
      ),
    );
  }

  Widget _psicologoCard(BuildContext context, PsicologoAdmin p, bool small) {
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
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: p.gradiente),
                ),
                child: Center(
                  child: Text(p.iniciales,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(p.nombre,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: PlatTheme.textDark,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(p.activo
                            ? BadgeStatus.activo
                            : BadgeStatus.inactivo),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(p.email,
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
            spacing: 20,
            runSpacing: 10,
            children: [
              _dato(Icons.people_alt_rounded, '${p.numPacientes} pacientes'),
              _dato(Icons.event_note_rounded, '${p.numCitas} citas'),
              _dato(Icons.apartment_rounded, p.clinica),
              _dato(Icons.workspace_premium_rounded, p.plan),
              _dato(Icons.login_rounded, p.ultimoAcceso),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _accion(context, 'Editar', Icons.edit_outlined),
              const SizedBox(width: 8),
              _accion(
                  context,
                  p.activo ? 'Desactivar' : 'Activar',
                  p.activo
                      ? Icons.toggle_on_rounded
                      : Icons.toggle_off_outlined),
              const Spacer(),
              _accion(context, 'Bloquear', Icons.block_rounded, danger: true),
            ],
          ),
        ],
      ),
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

  Widget _accion(BuildContext context, String label, IconData icon,
      {bool danger = false}) {
    final color = danger ? const Color(0xFFDC2626) : PlatTheme.textGray;
    return GestureDetector(
      onTap: () => _toast(context, '$label (demo)'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
              color: danger
                  ? const Color(0xFFFCA5A5)
                  : const Color(0xFFE8E4FF)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _btnNuevo(BuildContext context, String label) {
    return GestureDetector(
      onTap: () => _toast(context, '$label (demo)'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: PlatTheme.purple,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text('Nuevo',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: PlatTheme.darkNavy,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }
}
