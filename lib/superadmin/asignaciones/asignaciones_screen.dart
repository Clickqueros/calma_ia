import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import '../../core/supabase/supabase_config.dart';
import '../../core/auth/auth_service.dart';
import '../../core/auth/auth_screen.dart';
import '../../core/auth/perfil_service.dart';
import '../services/perfil_admin_service.dart';
import '../widgets/status_badge.dart';

/// Pantalla real: el SuperAdmin asigna pacientes a psicólogos.
/// Acción administrativa (no clínica). Requiere sesión de superadmin.
class AsignacionesScreen extends StatefulWidget {
  const AsignacionesScreen({super.key});

  @override
  State<AsignacionesScreen> createState() => _AsignacionesScreenState();
}

class _AsignacionesScreenState extends State<AsignacionesScreen> {
  bool _cargando = true;
  String _rol = '';
  List<PerfilAdmin> _pacientes = [];
  List<PerfilAdmin> _psicologos = [];

  @override
  void initState() {
    super.initState();
    _init();
    AuthService.instance.addListener(_init);
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_init);
    super.dispose();
  }

  Future<void> _init() async {
    if (!SupabaseConfig.isConfigured) {
      if (mounted) setState(() => _cargando = false);
      return;
    }
    if (!AuthService.instance.haySesion) {
      if (mounted) setState(() { _cargando = false; _rol = ''; });
      return;
    }
    setState(() => _cargando = true);
    _rol = await PerfilService.instance.miRol();
    if (_rol == 'superadmin') {
      _pacientes = await PerfilAdminService.instance.pacientes();
      _psicologos = await PerfilAdminService.instance.psicologos();
    }
    if (mounted) setState(() => _cargando = false);
  }

  String _nombrePsico(String? id) {
    if (id == null) return 'Sin asignar';
    final p = _psicologos.where((x) => x.id == id).toList();
    return p.isEmpty ? 'Psicólogo' : p.first.nombre;
  }

  @override
  Widget build(BuildContext context) {
    if (!SupabaseConfig.isConfigured) {
      return const EmptyState(
          icono: Icons.cloud_off_rounded,
          titulo: 'Backend no configurado',
          subtitulo: 'Conecta Supabase para gestionar asignaciones reales.');
    }
    if (_cargando) {
      return const Center(
          child: CircularProgressIndicator(color: PlatTheme.purple));
    }
    if (!AuthService.instance.haySesion || _rol != 'superadmin') {
      return _gateLogin();
    }
    return _contenido();
  }

  // ── Gate de login ──────────────────────────────────────────────────────────
  Widget _gateLogin() {
    final haySesion = AuthService.instance.haySesion;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.admin_panel_settings_rounded,
                color: PlatTheme.purple, size: 48),
            const SizedBox(height: 16),
            Text(
                haySesion
                    ? 'Tu cuenta no es de administrador'
                    : 'Inicia sesión como administrador',
                style: const TextStyle(
                    color: PlatTheme.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'Para asignar pacientes necesitas una cuenta de SuperAdmin.',
                textAlign: TextAlign.center,
                style: TextStyle(color: PlatTheme.textGray, fontSize: 13.5)),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () async {
                if (haySesion) {
                  await AuthService.instance.cerrarSesion();
                }
                if (!mounted) return;
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const AuthScreen(
                        permitirInvitado: false, soloLogin: true)));
                _init();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PlatTheme.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(haySesion ? 'Cambiar de cuenta' : 'Iniciar sesión',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Contenido ──────────────────────────────────────────────────────────────
  Widget _contenido() {
    final small = MediaQuery.of(context).size.width < 900;
    return RefreshIndicator(
      onRefresh: _init,
      child: ListView(
        padding: EdgeInsets.all(small ? 18 : 32),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EEFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD8CFFF)),
            ),
            child: const Row(
              children: [
                Icon(Icons.link_rounded, color: PlatTheme.purple, size: 19),
                SizedBox(width: 11),
                Expanded(
                  child: Text(
                      'Asignación administrativa. Defines qué psicólogo atiende a cada paciente. No accedes a su información clínica.',
                      style: TextStyle(
                          color: Color(0xFF4C1D95),
                          fontSize: 12.5, height: 1.4)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: _registrarPsicologo,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: PlatTheme.purple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_alt_1_rounded,
                      color: Colors.white, size: 19),
                  SizedBox(width: 8),
                  Text('Registrar nuevo psicólogo',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text('${_pacientes.length} pacientes',
                  style: const TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${_psicologos.length} psicólogos',
                  style: const TextStyle(
                      color: PlatTheme.textGray, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          if (_pacientes.isEmpty)
            const EmptyState(
                icono: Icons.person_off_rounded,
                titulo: 'No hay pacientes registrados',
                subtitulo: 'Aparecerán aquí cuando se registren en la app.')
          else
            ..._pacientes.map(_pacienteRow),
        ],
      ),
    );
  }

  Widget _pacienteRow(PerfilAdmin p) {
    final asignado = p.psicologoId != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFECFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
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
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.nombre,
                    style: const TextStyle(
                        color: PlatTheme.textDark,
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(asignado ? Icons.link_rounded : Icons.link_off_rounded,
                        size: 13,
                        color: asignado
                            ? const Color(0xFF059669)
                            : PlatTheme.textGray),
                    const SizedBox(width: 5),
                    Text(_nombrePsico(p.psicologoId),
                        style: TextStyle(
                            color: asignado
                                ? const Color(0xFF059669)
                                : PlatTheme.textGray,
                            fontSize: 12.5)),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _elegirPsicologo(p),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: PlatTheme.purple,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(asignado ? 'Cambiar' : 'Asignar',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _registrarPsicologo() async {
    final nombre = TextEditingController();
    final email = TextEditingController();
    final pass = TextEditingController();
    bool guardando = false;
    String? error;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Registrar psicólogo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    'Crea la cuenta del profesional. Él solo iniciará sesión; no se registra por su cuenta.',
                    style: TextStyle(color: PlatTheme.textGray, fontSize: 12.5)),
              ),
              const SizedBox(height: 14),
              _campoDialog(nombre, 'Nombre completo'),
              const SizedBox(height: 10),
              _campoDialog(email, 'Correo', tipo: TextInputType.emailAddress),
              const SizedBox(height: 10),
              _campoDialog(pass, 'Contraseña temporal', oculto: true),
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(error!,
                    style: const TextStyle(
                        color: Color(0xFFDC2626), fontSize: 12.5)),
              ],
            ],
          ),
          actions: [
            TextButton(
                onPressed: guardando ? null : () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar',
                    style: TextStyle(color: PlatTheme.textGray))),
            ElevatedButton(
              onPressed: guardando
                  ? null
                  : () async {
                      setLocal(() { guardando = true; error = null; });
                      final err =
                          await PerfilAdminService.instance.registrarPsicologo(
                        nombre: nombre.text,
                        email: email.text,
                        password: pass.text,
                      );
                      if (err == null) {
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        await _init();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Psicólogo creado ✓'),
                              backgroundColor: Color(0xFF059669),
                              behavior: SnackBarBehavior.floating));
                        }
                      } else {
                        setLocal(() { guardando = false; error = err; });
                      }
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor: PlatTheme.purple,
                  foregroundColor: Colors.white),
              child: guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoDialog(TextEditingController c, String hint,
      {bool oculto = false, TextInputType? tipo}) {
    return TextField(
      controller: c,
      obscureText: oculto,
      keyboardType: tipo,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: PlatTheme.softBg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE8E4FF))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE8E4FF))),
      ),
    );
  }

  Future<void> _elegirPsicologo(PerfilAdmin paciente) async {
    if (_psicologos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No hay psicólogos registrados todavía.'),
        backgroundColor: PlatTheme.darkNavy,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    final elegido = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFE8E4FF),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Asignar a ${paciente.nombre}',
                style: const TextStyle(
                    color: PlatTheme.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._psicologos.map((ps) => ListTile(
                  leading: const CircleAvatar(
                      backgroundColor: PlatTheme.purple,
                      child: Icon(Icons.medical_services_rounded,
                          color: Colors.white, size: 18)),
                  title: Text(ps.nombre),
                  subtitle: Text(ps.email,
                      style: const TextStyle(fontSize: 12)),
                  trailing: paciente.psicologoId == ps.id
                      ? const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF059669))
                      : null,
                  onTap: () => Navigator.of(ctx).pop(ps.id),
                )),
            if (paciente.psicologoId != null)
              ListTile(
                leading: const Icon(Icons.link_off_rounded,
                    color: Color(0xFFDC2626)),
                title: const Text('Quitar asignación',
                    style: TextStyle(color: Color(0xFFDC2626))),
                onTap: () => Navigator.of(ctx).pop('__none__'),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (elegido == null) return;
    final psicoId = elegido == '__none__' ? null : elegido;
    final error =
        await PerfilAdminService.instance.asignar(paciente.id, psicoId);
    if (!mounted) return;
    if (error == null) {
      await _init();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Asignación actualizada ✓'),
          backgroundColor: Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
}
