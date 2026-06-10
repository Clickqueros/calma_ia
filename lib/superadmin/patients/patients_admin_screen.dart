import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import '../../core/roles/user_role.dart';
import '../../core/access/clinical_data_guard.dart';
import '../../core/supabase/supabase_config.dart';
import '../services/perfil_admin_service.dart';
import '../widgets/status_badge.dart';

/// Pacientes reales (vista administrativa, datos NO clínicos).
class PatientsAdminScreen extends StatefulWidget {
  const PatientsAdminScreen({super.key});

  @override
  State<PatientsAdminScreen> createState() => _PatientsAdminScreenState();
}

class _PatientsAdminScreenState extends State<PatientsAdminScreen> {
  List<PerfilAdmin> _pacientes = [];
  Map<String, String> _psicologos = {}; // id -> nombre
  bool _cargando = true;

  bool get _small => MediaQuery.of(context).size.width < 900;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final todos = await PerfilAdminService.instance.listarTodos();
    if (mounted) {
      setState(() {
        _pacientes = todos.where((p) => p.rol == 'patient').toList();
        _psicologos = {
          for (final p in todos.where((p) => p.rol == 'psychologist'))
            p.id: p.nombre
        };
        _cargando = false;
      });
    }
  }

  String _nombrePsico(String? id) {
    if (id == null) return 'Sin asignar';
    return _psicologos[id] ?? 'Psicólogo';
  }

  String _fecha(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return '—';
    const m = ['', 'ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago',
      'sep', 'oct', 'nov', 'dic'];
    final l = d.toLocal();
    return '${l.day} ${m[l.month]} ${l.year}';
  }

  void _msg(String t, {bool ok = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(t),
      backgroundColor: ok ? const Color(0xFF059669) : const Color(0xFFDC2626),
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _cambiarEmail(PerfilAdmin p) async {
    final ctrl = TextEditingController(text: p.email);
    final nuevo = await _dialogo('Cambiar correo de ${p.nombre}', 'Nuevo correo', ctrl);
    if (nuevo == null || nuevo.isEmpty) return;
    final err = await PerfilAdminService.instance.cambiarEmail(p.id, nuevo);
    if (err == null) { _cargar(); _msg('Correo actualizado ✓', ok: true); }
    else { _msg(err); }
  }

  Future<void> _cambiarPassword(PerfilAdmin p) async {
    final ctrl = TextEditingController();
    final nueva = await _dialogo(
        'Nueva contraseña para ${p.nombre}', 'Mínimo 6 caracteres', ctrl,
        oculto: true);
    if (nueva == null || nueva.isEmpty) return;
    final err = await PerfilAdminService.instance.cambiarPassword(p.id, nueva);
    if (err == null) { _msg('Contraseña actualizada ✓', ok: true); }
    else { _msg(err); }
  }

  Future<void> _toggleActivo(PerfilAdmin p) async {
    final err = await PerfilAdminService.instance.setActivo(p.id, !p.activo);
    if (err == null) { _cargar(); } else { _msg(err); }
  }

  Future<String?> _dialogo(String titulo, String hint, TextEditingController ctrl,
      {bool oculto = false}) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(titulo,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          obscureText: oculto,
          autofocus: true,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: PlatTheme.softBg,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE8E4FF))),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar',
                  style: TextStyle(color: PlatTheme.textGray))),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            style: ElevatedButton.styleFrom(
                backgroundColor: PlatTheme.purple, foregroundColor: Colors.white),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!SupabaseConfig.isConfigured) {
      return const EmptyState(
          icono: Icons.cloud_off_rounded,
          titulo: 'Backend no configurado',
          subtitulo: 'Conecta Supabase para ver pacientes reales.');
    }
    if (_cargando) {
      return const Center(
          child: CircularProgressIndicator(color: PlatTheme.purple));
    }
    final pad = _small ? 18.0 : 32.0;
    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView(
        padding: EdgeInsets.all(pad),
        children: [
          _bannerPrivacidad(),
          const SizedBox(height: 18),
          Row(
            children: [
              Text('${_pacientes.length} pacientes registrados',
                  style: const TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    color: PlatTheme.textGray, size: 20),
                onPressed: _cargar,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_pacientes.isEmpty)
            const EmptyState(
                icono: Icons.people_outline_rounded,
                titulo: 'Aún no hay pacientes',
                subtitulo: 'Aparecerán aquí cuando se registren en la app.')
          else
            ..._pacientes.map(_pacienteCard),
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
                '(historia, diario) está protegida y requiere autorización.',
                style: TextStyle(
                    color: Color(0xFF4C1D95), fontSize: 12.5, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _pacienteCard(PerfilAdmin p) {
    final asignado = p.psicologoId != null;
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
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, gradient: PlatTheme.purpleGradient),
                child: Center(
                  child: Text(
                      p.nombre.isNotEmpty ? p.nombre[0].toUpperCase() : '?',
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
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFF2F0FF)),
          const SizedBox(height: 12),
          // Datos de registro
          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              _dato(asignado ? Icons.link_rounded : Icons.link_off_rounded,
                  'Psicólogo: ${_nombrePsico(p.psicologoId)}',
                  color: asignado ? const Color(0xFF059669) : null),
              if (p.telefono.isNotEmpty)
                _dato(Icons.phone_rounded, p.telefono),
              if (p.documento.isNotEmpty)
                _dato(Icons.badge_rounded, p.documento),
              _dato(Icons.calendar_today_rounded, 'Registro: ${_fecha(p.creadoEn)}'),
            ],
          ),
          const SizedBox(height: 14),
          // Acciones administrativas
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _accion('Correo', Icons.email_outlined, () => _cambiarEmail(p)),
              _accion('Contraseña', Icons.lock_outline_rounded,
                  () => _cambiarPassword(p)),
              _accion(p.activo ? 'Desactivar' : 'Activar',
                  Icons.toggle_on_rounded, () => _toggleActivo(p)),
              _accionClinica(p),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dato(IconData i, String t, {Color? color}) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(i, size: 14, color: color ?? PlatTheme.textGray),
          const SizedBox(width: 5),
          Text(t,
              style: TextStyle(
                  color: color ?? PlatTheme.textGray, fontSize: 12.5)),
        ],
      );

  Widget _accion(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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

  Widget _accionClinica(PerfilAdmin p) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ClinicalDataGuard(
          modulo: SensitiveModule.clinicalHistory,
          pacienteRef: p.email,
          pacienteId: p.id,
          builder: (_) => Scaffold(
            appBar: AppBar(
                backgroundColor: PlatTheme.darkNavy,
                title: const Text('Historia clínica',
                    style: TextStyle(color: Colors.white))),
            body: const Center(child: Text('Acceso autorizado')),
          ),
        ),
      )),
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
            Text('Historia clínica',
                style: TextStyle(
                    color: Color(0xFFD97706),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
