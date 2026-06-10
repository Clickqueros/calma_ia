import 'package:flutter/material.dart';
import '../../theme/plat_theme.dart';
import '../../../core/auth/perfil_service.dart';
import '../../../core/citas/citas_service.dart';

/// Pantalla real para que el paciente agende una cita con su psicólogo asignado.
class AgendarCitaRealScreen extends StatefulWidget {
  const AgendarCitaRealScreen({super.key});

  @override
  State<AgendarCitaRealScreen> createState() => _AgendarCitaRealScreenState();
}

class _AgendarCitaRealScreenState extends State<AgendarCitaRealScreen> {
  bool _cargando = true;
  String? _psicologoId;
  String _miNombre = '';
  List<CitaReal> _misCitas = [];

  DateTime? _fecha;
  String? _hora;
  String _modalidad = 'Videollamada';
  final _motivo = TextEditingController();
  bool _guardando = false;

  static const _horas = [
    '8:00 AM', '9:30 AM', '11:00 AM', '2:00 PM', '4:30 PM', '6:00 PM'
  ];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final perfil = await PerfilService.instance.miPerfil();
    _miNombre = (perfil?['nombre'] as String?) ?? '';
    _psicologoId = perfil?['psicologo_id']?.toString();
    _misCitas = await CitasService.instance.misCitasPaciente();
    if (mounted) setState(() => _cargando = false);
  }

  /// ¿Ya tengo una cita (no cancelada) ese día y hora?
  bool _ocupada(DateTime dia, String hora) {
    return _misCitas.any((c) =>
        c.estado != 'cancelada' &&
        c.hora == hora &&
        c.fecha.year == dia.year &&
        c.fecha.month == dia.month &&
        c.fecha.day == dia.day);
  }

  bool get _puedeAgendar =>
      _fecha != null &&
      _hora != null &&
      !_guardando &&
      !_ocupada(_fecha!, _hora!) &&
      !horaYaPaso(_fecha!, _hora!);

  Future<void> _agendar() async {
    if (_psicologoId == null) return;
    setState(() => _guardando = true);
    final error = await CitasService.instance.agendar(
      psicologoId: _psicologoId!,
      pacienteNombre: _miNombre,
      fecha: _fecha!,
      hora: _hora!,
      modalidad: _modalidad,
      motivo: _motivo.text.trim(),
    );
    if (!mounted) return;
    setState(() => _guardando = false);
    if (error == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6),
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xFFE8FAF0)),
                child: const Icon(Icons.check_rounded,
                    color: Color(0xFF059669), size: 32),
              ),
              const SizedBox(height: 16),
              const Text('¡Cita agendada!',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text(
                  'Tu psicólogo verá tu cita y la confirmará pronto.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: PlatTheme.textGray, fontSize: 13.5)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(true);
              },
              child: const Text('Listo',
                  style: TextStyle(color: PlatTheme.purple)),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlatTheme.softBg,
      appBar: AppBar(
        backgroundColor: PlatTheme.darkNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Agendar cita',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: PlatTheme.purple))
          : _psicologoId == null
              ? _sinPsicologo()
              : _formulario(),
    );
  }

  Widget _sinPsicologo() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link_off_rounded,
                color: PlatTheme.purple, size: 48),
            const SizedBox(height: 16),
            const Text('Aún no tienes psicólogo asignado',
                style: TextStyle(
                    color: PlatTheme.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'Conéctate primero con tu psicólogo (desde el diario) o pide a tu administrador que te asigne uno.',
                textAlign: TextAlign.center,
                style: TextStyle(color: PlatTheme.textGray, fontSize: 13.5)),
          ],
        ),
      ),
    );
  }

  Widget _formulario() {
    final dias = List.generate(14, (i) {
      final d = DateTime.now().add(Duration(days: i + 1));
      return d;
    }).where((d) => d.weekday != DateTime.saturday && d.weekday != DateTime.sunday).toList();

    const meses = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    const diasSem = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _label('1. Elige el día'),
        const SizedBox(height: 10),
        SizedBox(
          height: 84,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dias.length,
            itemBuilder: (ctx, i) {
              final d = dias[i];
              final sel = _fecha != null &&
                  _fecha!.day == d.day &&
                  _fecha!.month == d.month;
              return GestureDetector(
                onTap: () => setState(() {
                  _fecha = d;
                  // Deselecciona la hora si queda ocupada o ya pasó ese día.
                  if (_hora != null &&
                      (_ocupada(d, _hora!) || horaYaPaso(d, _hora!))) {
                    _hora = null;
                  }
                }),
                child: Container(
                  width: 64,
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
                      Text(diasSem[d.weekday],
                          style: TextStyle(
                              color: sel ? Colors.white70 : PlatTheme.textGray,
                              fontSize: 11)),
                      const SizedBox(height: 4),
                      Text('${d.day}',
                          style: TextStyle(
                              color: sel ? Colors.white : PlatTheme.textDark,
                              fontSize: 19,
                              fontWeight: FontWeight.bold)),
                      Text(meses[d.month],
                          style: TextStyle(
                              color: sel ? Colors.white70 : PlatTheme.textGray,
                              fontSize: 10)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        _label('2. Elige la hora'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _horas.map((h) {
            final sel = _hora == h;
            final ocupada = _fecha != null &&
                (_ocupada(_fecha!, h) || horaYaPaso(_fecha!, h));
            return GestureDetector(
              // Si está ocupada o ya pasó, no se puede seleccionar.
              onTap: ocupada ? null : () => setState(() => _hora = h),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                decoration: BoxDecoration(
                  color: ocupada
                      ? const Color(0xFFF1F0F5)
                      : (sel ? PlatTheme.purple : Colors.white),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: ocupada
                          ? const Color(0xFFE8E4FF)
                          : (sel ? PlatTheme.purple : const Color(0xFFE8E4FF))),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (ocupada) ...[
                      const Icon(Icons.lock_clock_rounded,
                          size: 13, color: Color(0xFFB0B0C0)),
                      const SizedBox(width: 4),
                    ],
                    Text(h,
                        style: TextStyle(
                            color: ocupada
                                ? const Color(0xFFB0B0C0)
                                : (sel ? Colors.white : PlatTheme.textDark),
                            fontSize: 13.5,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                            decoration: ocupada
                                ? TextDecoration.lineThrough
                                : null)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (_fecha != null &&
            _horas
                .where((h) => _ocupada(_fecha!, h) || horaYaPaso(_fecha!, h))
                .isNotEmpty) ...[
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 14, color: PlatTheme.textGray),
              SizedBox(width: 6),
              Expanded(
                child: Text('Las horas en gris ya pasaron o ya las tienes agendadas.',
                    style: TextStyle(color: PlatTheme.textGray, fontSize: 12)),
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        _label('3. Modalidad'),
        const SizedBox(height: 10),
        Row(
          children: [
            _modalidadChip('Videollamada', Icons.videocam_rounded),
            const SizedBox(width: 10),
            _modalidadChip('Presencial', Icons.place_rounded),
          ],
        ),
        const SizedBox(height: 24),
        _label('4. Motivo (opcional)'),
        const SizedBox(height: 10),
        TextField(
          controller: _motivo,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Ej: Seguimiento, ansiedad...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE8E4FF))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE8E4FF))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PlatTheme.purple)),
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _puedeAgendar ? _agendar : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: PlatTheme.purple,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFD4CAFF),
              padding: const EdgeInsets.symmetric(vertical: 16),
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
                : const Text('Confirmar cita',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _modalidadChip(String valor, IconData icon) {
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

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          color: PlatTheme.textDark,
          fontSize: 15,
          fontWeight: FontWeight.bold));
}
