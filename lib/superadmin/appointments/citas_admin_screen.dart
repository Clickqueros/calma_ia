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
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => _eliminar(c),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline_rounded,
                        size: 16, color: Color(0xFFDC2626)),
                    SizedBox(width: 6),
                    Text('Eliminar cita',
                        style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
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
}
