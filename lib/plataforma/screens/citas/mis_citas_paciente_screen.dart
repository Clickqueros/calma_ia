import 'package:flutter/material.dart';
import '../../theme/plat_theme.dart';
import '../../../core/auth/perfil_service.dart';
import '../../../core/citas/citas_service.dart';
import 'agendar_cita_real_screen.dart';

/// Sección "Citas" del paciente, con datos reales:
/// su psicólogo asignado + sus citas + agendar nueva.
class MisCitasPacienteScreen extends StatefulWidget {
  const MisCitasPacienteScreen({super.key});

  @override
  State<MisCitasPacienteScreen> createState() => _MisCitasPacienteScreenState();
}

class _MisCitasPacienteScreenState extends State<MisCitasPacienteScreen> {
  bool _cargando = true;
  Map<String, dynamic>? _psicologo;
  List<CitaReal> _citas = [];

  static const _meses = ['', 'enero', 'febrero', 'marzo', 'abril', 'mayo',
    'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
  static const _diasSem = ['', 'Lunes', 'Martes', 'Miércoles', 'Jueves',
    'Viernes', 'Sábado', 'Domingo'];

  bool get _small => MediaQuery.of(context).size.width < 800;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final psico = await PerfilService.instance.miPsicologo();
    final citas = await CitasService.instance.misCitasPaciente();
    if (mounted) {
      setState(() {
        _psicologo = psico;
        _citas = citas;
        _cargando = false;
      });
    }
  }

  Color _colorEstado(String e) => switch (e) {
        'confirmada' => const Color(0xFF059669),
        'cancelada' => const Color(0xFFDC2626),
        'completada' => const Color(0xFF6B7280),
        _ => PlatTheme.purple,
      };
  String _labelEstado(String e) => switch (e) {
        'confirmada' => 'Confirmada',
        'cancelada' => 'Cancelada',
        'completada' => 'Completada',
        _ => 'Agendada',
      };

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(
          child: CircularProgressIndicator(color: PlatTheme.purple));
    }
    final pad = _small ? 20.0 : 48.0;
    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView(
        padding: EdgeInsets.all(pad),
        children: [
          const Text('Mis citas',
              style: TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Agenda y revisa tus sesiones con tu psicólogo.',
              style: TextStyle(color: PlatTheme.textGray, fontSize: 15)),
          const SizedBox(height: 22),
          _psicologoCard(),
          const SizedBox(height: 22),
          const Text('Próximas y anteriores',
              style: TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_citas.isEmpty)
            _vacioCitas()
          else
            ..._citas.map(_citaCard),
        ],
      ),
    );
  }

  Widget _psicologoCard() {
    if (_psicologo == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFCD9A8)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Color(0xFFD97706)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                  'Aún no tienes un psicólogo asignado. Conéctate con uno desde tu diario o pídelo a tu administrador.',
                  style: TextStyle(
                      color: Color(0xFF92400E), fontSize: 13, height: 1.4)),
            ),
          ],
        ),
      );
    }
    final nombre = (_psicologo!['nombre'] as String?)?.isNotEmpty == true
        ? _psicologo!['nombre']
        : (_psicologo!['email'] ?? 'Tu psicólogo');
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PlatTheme.darkNavy, Color(0xFF2D1B69)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, gradient: PlatTheme.purpleGradient),
                child: const Icon(Icons.medical_services_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tu psicólogo',
                        style: TextStyle(
                            color: PlatTheme.softBlue, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(nombre,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const AgendarCitaRealScreen()));
                _cargar();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PlatTheme.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: const Icon(Icons.add_rounded, size: 19),
              label: const Text('Agendar nueva cita',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vacioCitas() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.event_note_rounded,
              size: 48, color: PlatTheme.textGray.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          const Text('No tienes citas todavía',
              style: TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Agenda tu primera sesión con el botón de arriba.',
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
              Icon(Icons.calendar_today_rounded,
                  size: 15, color: PlatTheme.purple),
              const SizedBox(width: 7),
              Text(
                  '${_diasSem[c.fecha.weekday]} ${c.fecha.day} de ${_meses[c.fecha.month]}',
                  style: const TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
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
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 14, color: PlatTheme.textGray),
              const SizedBox(width: 5),
              Text(c.hora,
                  style: const TextStyle(
                      color: PlatTheme.textGray, fontSize: 13)),
              const SizedBox(width: 16),
              Icon(video ? Icons.videocam_rounded : Icons.place_rounded,
                  size: 14, color: PlatTheme.textGray),
              const SizedBox(width: 5),
              Text(c.modalidad,
                  style: const TextStyle(
                      color: PlatTheme.textGray, fontSize: 13)),
            ],
          ),
          if (c.motivo.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(c.motivo,
                style: const TextStyle(
                    color: PlatTheme.textGray, fontSize: 13, height: 1.4)),
          ],
        ],
      ),
    );
  }
}
