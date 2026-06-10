import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import '../../core/supabase/supabase_config.dart';
import '../../core/citas/citas_service.dart';
import '../services/perfil_admin_service.dart';
import '../widgets/status_badge.dart';

/// Vista administrativa de citas: el SuperAdmin puede ver y ELIMINAR citas.
class CitasAdminScreen extends StatefulWidget {
  const CitasAdminScreen({super.key});

  @override
  State<CitasAdminScreen> createState() => _CitasAdminScreenState();
}

class _CitasAdminScreenState extends State<CitasAdminScreen> {
  List<CitaReal> _citas = [];
  Map<String, String> _psicologos = {};
  bool _cargando = true;

  static const _meses = ['', 'ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul',
    'ago', 'sep', 'oct', 'nov', 'dic'];
  static const _dias = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  bool get _small => MediaQuery.of(context).size.width < 900;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final citas = await PerfilAdminService.instance.listarCitas();
    final todos = await PerfilAdminService.instance.listarTodos();
    if (mounted) {
      setState(() {
        _citas = citas;
        _psicologos = {
          for (final p in todos.where((p) => p.rol == 'psychologist'))
            p.id: p.nombre
        };
        _cargando = false;
      });
    }
  }

  Color _color(String e) => switch (e) {
        'confirmada' => const Color(0xFF059669),
        'cancelada' => const Color(0xFFDC2626),
        'completada' => const Color(0xFF6B7280),
        _ => PlatTheme.purple,
      };
  String _label(String e) => switch (e) {
        'confirmada' => 'Confirmada',
        'cancelada' => 'Cancelada',
        'completada' => 'Completada',
        _ => 'Agendada',
      };

  Future<void> _eliminar(CitaReal c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Eliminar cita',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Text(
            '¿Eliminar la cita de ${c.pacienteNombre} del ${c.fecha.day}/${c.fecha.month} a las ${c.hora}? Esta acción no se puede deshacer.',
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
    final err = await PerfilAdminService.instance.eliminarCita(c.id);
    if (!mounted) return;
    if (err == null) {
      _cargar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Cita eliminada ✓'),
        backgroundColor: Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!SupabaseConfig.isConfigured) {
      return const EmptyState(
          icono: Icons.cloud_off_rounded,
          titulo: 'Backend no configurado',
          subtitulo: 'Conecta Supabase para ver las citas.');
    }
    if (_cargando) {
      return const Center(
          child: CircularProgressIndicator(color: PlatTheme.purple));
    }
    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView(
        padding: EdgeInsets.all(_small ? 18 : 32),
        children: [
          Row(
            children: [
              Text('${_citas.length} citas en total',
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
          if (_citas.isEmpty)
            const EmptyState(
                icono: Icons.event_busy_rounded,
                titulo: 'No hay citas',
                subtitulo: 'Aparecerán aquí cuando los pacientes agenden.')
          else
            ..._citas.map(_citaCard),
        ],
      ),
    );
  }

  Widget _citaCard(CitaReal c) {
    final color = _color(c.estado);
    final psico = _psicologos[c.psicologoId] ?? 'Psicólogo';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEFECFF))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                    c.pacienteNombre.isNotEmpty ? c.pacienteNombre : 'Paciente',
                    style: const TextStyle(
                        color: PlatTheme.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(_label(c.estado),
                    style: TextStyle(
                        color: color,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              _dato(Icons.medical_services_rounded, psico),
              _dato(Icons.calendar_today_rounded,
                  '${_dias[c.fecha.weekday]} ${c.fecha.day} ${_meses[c.fecha.month]}'),
              _dato(Icons.schedule_rounded, c.hora),
              _dato(
                  c.modalidad == 'Videollamada'
                      ? Icons.videocam_rounded
                      : Icons.place_rounded,
                  c.modalidad),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFF2F0FF)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('Reagendar', Icons.edit_calendar_rounded,
                  const Color(0xFF6B4EFF), () => _reagendar(c)),
              _btn('Cambiar psicólogo', Icons.swap_horiz_rounded,
                  const Color(0xFF0891B2), () => _cambiarPsicologo(c)),
              _btn('Cambiar estado', Icons.flag_rounded,
                  const Color(0xFFD97706), () => _cambiarEstado(c)),
              _btn('Eliminar', Icons.delete_outline_rounded,
                  const Color(0xFFDC2626), () => _eliminar(c),
                  outline: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btn(String label, IconData icon, Color color, VoidCallback onTap,
      {bool outline = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: outline ? Colors.transparent : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
              color: outline ? const Color(0xFFFCA5A5) : Colors.transparent),
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

  // ── Reagendar ────────────────────────────────────────────────────────────────
  Future<void> _reagendar(CitaReal c) async {
    final cambio = await showModalBottomSheet<({DateTime fecha, String hora, String modalidad})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReagendarSheet(cita: c),
    );
    if (cambio == null) return;
    final err = await PerfilAdminService.instance.actualizarCita(
      c.id,
      fecha: cambio.fecha,
      hora: cambio.hora,
      modalidad: cambio.modalidad,
    );
    if (!mounted) return;
    if (err == null) {
      _cargar();
      _toast('Cita reagendada ✓', ok: true);
    } else {
      _toast(err);
    }
  }

  // ── Cambiar psicólogo ────────────────────────────────────────────────────────
  Future<void> _cambiarPsicologo(CitaReal c) async {
    if (_psicologos.isEmpty) {
      _toast('No hay psicólogos registrados.');
      return;
    }
    final nuevo = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            const Text('Reasignar a otro psicólogo',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._psicologos.entries.map((e) => ListTile(
                  leading: const CircleAvatar(
                      backgroundColor: PlatTheme.purple,
                      child: Icon(Icons.medical_services_rounded,
                          color: Colors.white, size: 18)),
                  title: Text(e.value),
                  trailing: c.psicologoId == e.key
                      ? const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF059669))
                      : null,
                  onTap: () => Navigator.of(ctx).pop(e.key),
                )),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (nuevo == null || nuevo == c.psicologoId) return;
    final err = await PerfilAdminService.instance
        .actualizarCita(c.id, psicologoId: nuevo);
    if (!mounted) return;
    if (err == null) {
      _cargar();
      _toast('Psicólogo de la cita actualizado ✓', ok: true);
    } else {
      _toast(err);
    }
  }

  // ── Cambiar estado ───────────────────────────────────────────────────────────
  Future<void> _cambiarEstado(CitaReal c) async {
    const estados = ['agendada', 'confirmada', 'completada', 'cancelada'];
    final nuevo = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            const Text('Cambiar estado',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...estados.map((e) => ListTile(
                  leading: Icon(Icons.circle, color: _color(e), size: 14),
                  title: Text(_label(e)),
                  trailing: c.estado == e
                      ? const Icon(Icons.check_rounded,
                          color: Color(0xFF059669))
                      : null,
                  onTap: () => Navigator.of(ctx).pop(e),
                )),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (nuevo == null) return;
    final err =
        await PerfilAdminService.instance.actualizarCita(c.id, estado: nuevo);
    if (!mounted) return;
    if (err == null) {
      _cargar();
      _toast('Estado actualizado ✓', ok: true);
    } else {
      _toast(err);
    }
  }

  void _toast(String t, {bool ok = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(t),
      backgroundColor: ok ? const Color(0xFF059669) : const Color(0xFFDC2626),
      behavior: SnackBarBehavior.floating,
    ));
  }

  Widget _dato(IconData i, String t) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(i, size: 14, color: PlatTheme.textGray),
          const SizedBox(width: 5),
          Text(t, style: const TextStyle(color: PlatTheme.textGray, fontSize: 12.5)),
        ],
      );
}

// ── Sheet para reagendar ──────────────────────────────────────────────────────

class _ReagendarSheet extends StatefulWidget {
  final CitaReal cita;
  const _ReagendarSheet({required this.cita});

  @override
  State<_ReagendarSheet> createState() => _ReagendarSheetState();
}

class _ReagendarSheetState extends State<_ReagendarSheet> {
  late DateTime _fecha = widget.cita.fecha;
  late String _hora = widget.cita.hora;
  late String _modalidad = widget.cita.modalidad;

  static const _horas = [
    '8:00 AM', '9:30 AM', '11:00 AM', '2:00 PM', '4:30 PM', '6:00 PM'
  ];
  static const _meses = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul',
    'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
  static const _diasSem = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context) {
    final dias = List.generate(21, (i) => DateTime.now().add(Duration(days: i)))
        .where((d) => d.weekday != DateTime.saturday && d.weekday != DateTime.sunday)
        .toList();
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Reagendar cita',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const Text('Nuevo día',
                    style: TextStyle(
                        color: PlatTheme.textGray,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: dias.length,
                    itemBuilder: (ctx, i) {
                      final d = dias[i];
                      final sel = _fecha.year == d.year &&
                          _fecha.month == d.month &&
                          _fecha.day == d.day;
                      return GestureDetector(
                        onTap: () => setState(() => _fecha = d),
                        child: Container(
                          width: 62,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: sel ? PlatTheme.purple : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: sel
                                    ? PlatTheme.purple
                                    : const Color(0xFFE8E4FF)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_diasSem[d.weekday],
                                  style: TextStyle(
                                      color: sel
                                          ? Colors.white70
                                          : PlatTheme.textGray,
                                      fontSize: 11)),
                              const SizedBox(height: 3),
                              Text('${d.day}',
                                  style: TextStyle(
                                      color: sel
                                          ? Colors.white
                                          : PlatTheme.textDark,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text(_meses[d.month],
                                  style: TextStyle(
                                      color: sel
                                          ? Colors.white70
                                          : PlatTheme.textGray,
                                      fontSize: 10)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                const Text('Nueva hora',
                    style: TextStyle(
                        color: PlatTheme.textGray,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _horas.map((h) {
                    final sel = _hora == h;
                    final paso = horaYaPaso(_fecha, h);
                    return GestureDetector(
                      onTap: paso ? null : () => setState(() => _hora = h),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 11),
                        decoration: BoxDecoration(
                          color: paso
                              ? const Color(0xFFF1F0F5)
                              : (sel ? PlatTheme.purple : Colors.white),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: paso
                                  ? const Color(0xFFE8E4FF)
                                  : (sel
                                      ? PlatTheme.purple
                                      : const Color(0xFFE8E4FF))),
                        ),
                        child: Text(h,
                            style: TextStyle(
                                color: paso
                                    ? const Color(0xFFB0B0C0)
                                    : (sel
                                        ? Colors.white
                                        : PlatTheme.textDark),
                                fontSize: 13.5,
                                fontWeight:
                                    sel ? FontWeight.w700 : FontWeight.w500,
                                decoration: paso
                                    ? TextDecoration.lineThrough
                                    : null)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                const Text('Modalidad',
                    style: TextStyle(
                        color: PlatTheme.textGray,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _modChip('Videollamada', Icons.videocam_rounded),
                    const SizedBox(width: 10),
                    _modChip('Presencial', Icons.place_rounded),
                  ],
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: horaYaPaso(_fecha, _hora)
                        ? null
                        : () => Navigator.of(context).pop(
                            (fecha: _fecha, hora: _hora, modalidad: _modalidad)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PlatTheme.purple,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFD4CAFF),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                        horaYaPaso(_fecha, _hora)
                            ? 'Esa hora ya pasó'
                            : 'Guardar cambios',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modChip(String valor, IconData icon) {
    final sel = _modalidad == valor;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _modalidad = valor),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: sel ? PlatTheme.purple.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: sel ? PlatTheme.purple : const Color(0xFFE8E4FF),
                width: sel ? 1.5 : 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: sel ? PlatTheme.purple : PlatTheme.textGray, size: 18),
              const SizedBox(width: 7),
              Text(valor,
                  style: TextStyle(
                      color: sel ? PlatTheme.purple : PlatTheme.textGray,
                      fontSize: 13,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
