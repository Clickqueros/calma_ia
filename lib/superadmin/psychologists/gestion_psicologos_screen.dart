import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import '../../core/supabase/supabase_config.dart';
import '../../core/clinica/archivo_picker.dart';
import '../../core/match/match_catalogos.dart';
import '../services/perfil_admin_service.dart';
import '../widgets/status_badge.dart';

/// Gestión real de psicólogos por el SuperAdmin:
/// crear, editar datos, subir tarjeta, cambiar correo/contraseña, eliminar.
class GestionPsicologosScreen extends StatefulWidget {
  const GestionPsicologosScreen({super.key});

  @override
  State<GestionPsicologosScreen> createState() =>
      _GestionPsicologosScreenState();
}

class _GestionPsicologosScreenState extends State<GestionPsicologosScreen> {
  List<PerfilAdmin> _psicologos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final lista = await PerfilAdminService.instance.psicologos();
    if (mounted) setState(() { _psicologos = lista; _cargando = false; });
  }

  void _msg(String t, {bool ok = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(t),
      backgroundColor: ok ? const Color(0xFF059669) : const Color(0xFFDC2626),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (!SupabaseConfig.isConfigured) {
      return const EmptyState(
          icono: Icons.cloud_off_rounded,
          titulo: 'Backend no configurado',
          subtitulo: 'Conecta Supabase para gestionar psicólogos.');
    }
    final small = MediaQuery.of(context).size.width < 900;
    return Scaffold(
      backgroundColor: PlatTheme.softBg,
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: PlatTheme.purple))
          : RefreshIndicator(
              onRefresh: _cargar,
              child: ListView(
                padding: EdgeInsets.all(small ? 18 : 32),
                children: [
                  GestureDetector(
                    onTap: _crear,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                          color: PlatTheme.purple,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add_alt_1_rounded,
                              color: Colors.white, size: 19),
                          SizedBox(width: 8),
                          Text('Crear nuevo psicólogo',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('${_psicologos.length} psicólogos registrados',
                      style: const TextStyle(
                          color: PlatTheme.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (_psicologos.isEmpty)
                    const EmptyState(
                        icono: Icons.medical_services_outlined,
                        titulo: 'Sin psicólogos',
                        subtitulo: 'Crea el primero con el botón de arriba.')
                  else
                    ..._psicologos.map(_card),
                ],
              ),
            ),
    );
  }

  Widget _card(PerfilAdmin p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEFECFF))),
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
                            fontSize: 17))),
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
          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              if (p.documento.isNotEmpty) _dato(Icons.badge_rounded, p.documento),
              if (p.telefono.isNotEmpty) _dato(Icons.phone_rounded, p.telefono),
              if (p.registroProfesional.isNotEmpty)
                _dato(Icons.verified_rounded, 'RM ${p.registroProfesional}'),
              if (p.tarjetaUrl.isNotEmpty)
                _dato(Icons.badge_outlined, 'Tarjeta adjunta'),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _accion('Editar', Icons.edit_outlined, () => _editar(p)),
              _accion('Correo', Icons.email_outlined, () => _cambiarEmail(p)),
              _accion('Contraseña', Icons.lock_outline_rounded,
                  () => _cambiarPassword(p)),
              _accion(p.activo ? 'Desactivar' : 'Activar',
                  Icons.toggle_on_rounded, () => _toggleActivo(p)),
              _accion('Eliminar', Icons.delete_outline_rounded,
                  () => _eliminar(p),
                  danger: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dato(IconData i, String t) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(i, size: 14, color: PlatTheme.textGray),
          const SizedBox(width: 5),
          Text(t, style: const TextStyle(color: PlatTheme.textGray, fontSize: 12.5)),
        ],
      );

  Widget _accion(String label, IconData icon, VoidCallback onTap,
      {bool danger = false}) {
    final color = danger ? const Color(0xFFDC2626) : PlatTheme.textGray;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
              color: danger ? const Color(0xFFFCA5A5) : const Color(0xFFE8E4FF)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12.5, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ── Crear ────────────────────────────────────────────────────────────────────
  Future<void> _crear() async {
    final r = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FormPsicologo(),
    );
    if (r == true) {
      _cargar();
      _msg('Psicólogo creado ✓', ok: true);
    }
  }

  // ── Editar datos ─────────────────────────────────────────────────────────────
  Future<void> _editar(PerfilAdmin p) async {
    final r = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FormPsicologo(existente: p),
    );
    if (r == true) {
      _cargar();
      _msg('Datos actualizados ✓', ok: true);
    }
  }

  // ── Cambiar correo ───────────────────────────────────────────────────────────
  Future<void> _cambiarEmail(PerfilAdmin p) async {
    final ctrl = TextEditingController(text: p.email);
    final nuevo = await _dialogoCampo(
        'Cambiar correo de ${p.nombre}', 'Nuevo correo', ctrl);
    if (nuevo == null || nuevo.isEmpty) return;
    final err = await PerfilAdminService.instance.cambiarEmail(p.id, nuevo);
    if (err == null) { _cargar(); _msg('Correo actualizado ✓', ok: true); }
    else { _msg(err); }
  }

  // ── Cambiar contraseña ───────────────────────────────────────────────────────
  Future<void> _cambiarPassword(PerfilAdmin p) async {
    final ctrl = TextEditingController();
    final nueva = await _dialogoCampo(
        'Nueva contraseña para ${p.nombre}', 'Mínimo 6 caracteres', ctrl,
        oculto: true);
    if (nueva == null || nueva.isEmpty) return;
    final err = await PerfilAdminService.instance.cambiarPassword(p.id, nueva);
    if (err == null) { _msg('Contraseña actualizada ✓', ok: true); }
    else { _msg(err); }
  }

  // ── Activar / desactivar ─────────────────────────────────────────────────────
  Future<void> _toggleActivo(PerfilAdmin p) async {
    final err = await PerfilAdminService.instance.setActivo(p.id, !p.activo);
    if (err == null) { _cargar(); }
    else { _msg(err); }
  }

  // ── Eliminar ─────────────────────────────────────────────────────────────────
  Future<void> _eliminar(PerfilAdmin p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Eliminar psicólogo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Text(
            '¿Seguro que deseas eliminar la cuenta de ${p.nombre}? Esta acción no se puede deshacer.',
            style: const TextStyle(color: PlatTheme.textGray, fontSize: 14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar',
                  style: TextStyle(color: PlatTheme.textGray))),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final err = await PerfilAdminService.instance.eliminar(p.id);
    if (err == null) { _cargar(); _msg('Psicólogo eliminado ✓', ok: true); }
    else { _msg(err); }
  }

  Future<String?> _dialogoCampo(
      String titulo, String hint, TextEditingController ctrl,
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
}

// ── Formulario crear/editar psicólogo ────────────────────────────────────────

class _FormPsicologo extends StatefulWidget {
  final PerfilAdmin? existente;
  const _FormPsicologo({this.existente});

  @override
  State<_FormPsicologo> createState() => _FormPsicologoState();
}

class _FormPsicologoState extends State<_FormPsicologo> {
  late final _nombre = TextEditingController(text: widget.existente?.nombre ?? '');
  late final _email = TextEditingController(text: widget.existente?.email ?? '');
  final _password = TextEditingController();
  late final _telefono =
      TextEditingController(text: widget.existente?.telefono ?? '');
  late final _documento =
      TextEditingController(text: widget.existente?.documento ?? '');
  late final _registro = TextEditingController(
      text: widget.existente?.registroProfesional ?? '');
  late final _precio = TextEditingController(
      text: (widget.existente?.precio ?? 0) > 0
          ? '${widget.existente!.precio}'
          : '');
  late final _bio =
      TextEditingController(text: widget.existente?.bio ?? '');
  late String _enfoque = widget.existente?.enfoque ?? '';
  late final Set<String> _areas = ((widget.existente?.areas ?? '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty))
      .toSet();

  String _tarjetaUrl = '';
  String _tarjetaNombre = '';
  bool _subiendo = false;
  bool _guardando = false;
  String? _error;

  bool get _esEdicion => widget.existente != null;

  @override
  void initState() {
    super.initState();
    _tarjetaUrl = widget.existente?.tarjetaUrl ?? '';
    if (_tarjetaUrl.isNotEmpty) _tarjetaNombre = 'Tarjeta actual';
  }

  @override
  void dispose() {
    for (final c in [
      _nombre, _email, _password, _telefono, _documento, _registro,
      _precio, _bio
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _subirTarjeta() async {
    final a = await elegirArchivo();
    if (a == null) return;
    setState(() => _subiendo = true);
    final url = await PerfilAdminService.instance.subirTarjeta(a.nombre, a.bytes);
    if (!mounted) return;
    setState(() {
      _subiendo = false;
      if (url != null) { _tarjetaUrl = url; _tarjetaNombre = a.nombre; }
      else { _error = 'No se pudo subir la tarjeta (¿bucket "adjuntos"?).'; }
    });
  }

  Future<void> _guardar() async {
    setState(() { _guardando = true; _error = null; });
    String? err;
    final areasStr = _areas.join(', ');
    final precioNum = int.tryParse(_precio.text.trim()) ?? 0;
    if (_esEdicion) {
      err = await PerfilAdminService.instance.actualizarDatos(
        widget.existente!.id,
        nombre: _nombre.text,
        telefono: _telefono.text,
        documento: _documento.text,
        registroProfesional: _registro.text,
        tarjetaUrl: _tarjetaUrl,
        enfoque: _enfoque,
        areas: areasStr,
        precio: precioNum,
        bio: _bio.text,
      );
    } else {
      err = await PerfilAdminService.instance.crearPsicologo(
        nombre: _nombre.text,
        email: _email.text,
        password: _password.text,
        telefono: _telefono.text,
        documento: _documento.text,
        registroProfesional: _registro.text,
        tarjetaUrl: _tarjetaUrl,
        enfoque: _enfoque,
        areas: areasStr,
        precio: precioNum,
        bio: _bio.text,
      );
    }
    if (!mounted) return;
    setState(() => _guardando = false);
    if (err == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFE8E4FF),
                  borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(_esEdicion ? 'Editar psicólogo' : 'Nuevo psicólogo',
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              children: [
                _campo('Nombre completo', _nombre),
                _campo('Documento (CC)', _documento),
                _campo('Teléfono', _telefono),
                _campo('Registro profesional', _registro),
                if (!_esEdicion) ...[
                  _campo('Correo de inicio de sesión', _email),
                  _campo('Contraseña temporal', _password, oculto: true),
                ] else
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: PlatTheme.softBg,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(
                        'Correo: ${widget.existente!.email}\nUsa los botones "Correo" y "Contraseña" para cambiarlos.',
                        style: const TextStyle(
                            color: PlatTheme.textGray, fontSize: 12.5)),
                  ),
                // ── Datos para el match ──────────────────────────────────
                const SizedBox(height: 4),
                const Text('PERFIL PARA EL MATCH',
                    style: TextStyle(
                        color: PlatTheme.purple,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8)),
                const SizedBox(height: 12),
                const Text('Enfoque',
                    style: TextStyle(
                        color: PlatTheme.textGray,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                      color: PlatTheme.softBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE8E4FF))),
                  child: DropdownButton<String>(
                    value: _enfoque.isEmpty ? null : _enfoque,
                    hint: const Text('Seleccionar',
                        style:
                            TextStyle(color: PlatTheme.textGray, fontSize: 13.5)),
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items: enfoquesTerapeuticos
                        .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e,
                                style: const TextStyle(fontSize: 13.5))))
                        .toList(),
                    onChanged: (v) => setState(() => _enfoque = v ?? ''),
                  ),
                ),
                const Text('Áreas que trata',
                    style: TextStyle(
                        color: PlatTheme.textGray,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: areasConsulta.map((a) {
                    final sel = _areas.contains(a);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (sel) {
                          _areas.remove(a);
                        } else {
                          _areas.add(a);
                        }
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? PlatTheme.purple : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: sel
                                  ? PlatTheme.purple
                                  : const Color(0xFFE8E4FF)),
                        ),
                        child: Text(a,
                            style: TextStyle(
                                color:
                                    sel ? Colors.white : PlatTheme.textDark,
                                fontSize: 12.5,
                                fontWeight:
                                    sel ? FontWeight.w700 : FontWeight.w500)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                _campo('Precio por sesión (\$)', _precio),
                const Text('Bio / presentación',
                    style: TextStyle(
                        color: PlatTheme.textGray,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: TextField(
                    controller: _bio,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Breve presentación profesional...',
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
                  ),
                ),
                const Text('Tarjeta profesional',
                    style: TextStyle(
                        color: PlatTheme.textGray,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                _tarjetaWidget(),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: const TextStyle(
                          color: Color(0xFFDC2626), fontSize: 12.5)),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _guardando ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PlatTheme.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _guardando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : Text(_esEdicion ? 'Guardar cambios' : 'Crear psicólogo',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaWidget() {
    if (_subiendo) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: PlatTheme.softBg, borderRadius: BorderRadius.circular(10)),
        child: const Row(children: [
          SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.5)),
          SizedBox(width: 12),
          Text('Subiendo...',
              style: TextStyle(color: PlatTheme.textGray, fontSize: 13.5)),
        ]),
      );
    }
    if (_tarjetaUrl.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
            color: const Color(0xFFE8FAF0),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFA7E8C8))),
        child: Row(children: [
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF059669), size: 18),
          const SizedBox(width: 10),
          Expanded(
              child: Text(_tarjetaNombre,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF065F46), fontSize: 13))),
          GestureDetector(
            onTap: () => setState(() { _tarjetaUrl = ''; _tarjetaNombre = ''; }),
            child: const Icon(Icons.close_rounded,
                color: Color(0xFFDC2626), size: 18),
          ),
        ]),
      );
    }
    return GestureDetector(
      onTap: _subirTarjeta,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: PlatTheme.softBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE8E4FF))),
        child: const Row(children: [
          Icon(Icons.upload_file_rounded, color: PlatTheme.purple, size: 20),
          SizedBox(width: 12),
          Text('Subir tarjeta (PDF o imagen)',
              style: TextStyle(color: PlatTheme.textDark, fontSize: 13.5)),
        ]),
      ),
    );
  }

  Widget _campo(String label, TextEditingController c, {bool oculto = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: PlatTheme.textGray,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: c,
            obscureText: oculto,
            decoration: InputDecoration(
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
          ),
        ],
      ),
    );
  }
}
