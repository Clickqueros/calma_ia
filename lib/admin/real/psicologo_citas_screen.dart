import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import '../../core/citas/citas_service.dart';

/// Citas reales del psicólogo. Puede confirmar, cancelar o completar.
class PsicologoCitasScreen extends StatefulWidget {
  const PsicologoCitasScreen({super.key});

  @override
  State<PsicologoCitasScreen> createState() => _PsicologoCitasScreenState();
}

class _PsicologoCitasScreenState extends State<PsicologoCitasScreen> {
  List<CitaReal> _citas = [];
  bool _cargando = true;

  static const _meses = ['', 'enero', 'febrero', 'marzo', 'abril', 'mayo',
    'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
  static const _dias = ['', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final citas = await CitasService.instance.misCitasPsicologo();
    if (mounted) {
      setState(() {
        _citas = citas;
        _cargando = false;
      });
    }
  }

  Color _colorEstado(String e) => switch (e) {
        'confirmada' => const Color(0xFF059669),
        'cancelada' => const Color(0xFFDC2626),
        'completada' => const Color(0xFF6B7280),
        _ => const Color(0xFF6B4EFF), // agendada
      };

  String _labelEstado(String e) => switch (e) {
        'confirmada' => 'Confirmada',
        'cancelada' => 'Cancelada',
        'completada' => 'Completada',
        _ => 'Agendada',
      };

  Future<void> _cambiar(CitaReal c, String estado) async {
    final error = await CitasService.instance.cambiarEstado(c.id, estado);
    if (!mounted) return;
    if (error == null) {
      _cargar();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error), backgroundColor: const Color(0xFFDC2626)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlatTheme.softBg,
      appBar: AppBar(
        backgroundColor: PlatTheme.darkNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Mis citas',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _cargar,
          ),
        ],
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: PlatTheme.purple))
          : _citas.isEmpty
              ? _vacio()
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: _citas.map(_citaCard).toList(),
                  ),
                ),
    );
  }

  Widget _vacio() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy_rounded,
              size: 52, color: PlatTheme.textGray.withValues(alpha: 0.4)),
          const SizedBox(height: 14),
          const Text('No tienes citas agendadas',
              style: TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Tus pacientes pueden agendar desde su diario.',
              style: TextStyle(color: PlatTheme.textGray, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _citaCard(CitaReal c) {
    final color = _colorEstado(c.estado);
    final video = c.modalidad == 'Videollamada';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFECFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, gradient: PlatTheme.purpleGradient),
                child: Center(
                  child: Text(
                      c.pacienteNombre.isNotEmpty
                          ? c.pacienteNombre[0].toUpperCase()
                          : '?',
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
                    Text(
                        c.pacienteNombre.isNotEmpty
                            ? c.pacienteNombre
                            : 'Paciente',
                        style: const TextStyle(
                            color: PlatTheme.textDark,
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold)),
                    if (c.motivo.isNotEmpty)
                      Text(c.motivo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: PlatTheme.textGray, fontSize: 12.5)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(_labelEstado(c.estado),
                    style: TextStyle(
                        color: color,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFF2F0FF)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 14, color: PlatTheme.textGray),
              const SizedBox(width: 6),
              Text('${_dias[c.fecha.weekday]} ${c.fecha.day} ${_meses[c.fecha.month]}',
                  style: const TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 14),
              Icon(Icons.schedule_rounded, size: 14, color: PlatTheme.textGray),
              const SizedBox(width: 5),
              Text(c.hora,
                  style: const TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 14),
              Icon(video ? Icons.videocam_rounded : Icons.place_rounded,
                  size: 14, color: PlatTheme.textGray),
            ],
          ),
          if (c.estado == 'agendada' || c.estado == 'confirmada') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (c.estado == 'agendada')
                  Expanded(
                    child: _btn('Confirmar', const Color(0xFF059669),
                        () => _cambiar(c, 'confirmada')),
                  ),
                if (c.estado == 'confirmada')
                  Expanded(
                    child: _btn('Completar', const Color(0xFF6B7280),
                        () => _cambiar(c, 'completada')),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: _btn('Cancelar', const Color(0xFFDC2626),
                      () => _cambiar(c, 'cancelada'),
                      outline: true),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _btn(String label, Color color, VoidCallback onTap,
      {bool outline = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: outline ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: color),
        ),
        child: Text(label,
            style: TextStyle(
                color: outline ? color : Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}
