import 'package:flutter/material.dart';
import 'models/terapeuta_model.dart';
import 'models/cita_model.dart';
import 'widgets/paso_indicator.dart';
import 'widgets/terapeuta_card.dart';
import 'widgets/calendario_widget.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen>
    with SingleTickerProviderStateMixin {
  int _paso = 0;

  Terapeuta? _terapeuta;
  DateTime? _fecha;
  String? _hora;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  static const _purple = Color(0xFF6B4EFF);
  static const _textDark = Color(0xFF1A1A2E);
  static const _textGray = Color(0xFF6B7280);
  static const _softBg = Color(0xFFF8F7FF);

  static const _pasos = ['Terapeuta', 'Fecha', 'Horario', 'Confirmar'];

  bool get _small => MediaQuery.of(context).size.width < 800;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _slideAnim =
        Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _irA(int nuevoPaso, {bool forward = true}) {
    _animCtrl.reverse().then((_) {
      setState(() {
        _paso = nuevoPaso;
      });
      _animCtrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pad = _small ? 20.0 : 48.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 28),
            _buildPasoBar(),
            const SizedBox(height: 36),
            FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: _buildPasoActual(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    const titulos = [
      ('Selecciona tu terapeuta', 'Elige al profesional con el que quieres trabajar.'),
      ('¿Cuándo quieres tu cita?', 'Selecciona un día disponible en el calendario.'),
      ('Elige tu horario', 'Escoge el horario que mejor se adapte a ti.'),
      ('Tu cita está lista', 'Revisa los detalles antes de confirmar.'),
    ];

    final (titulo, sub) = titulos[_paso];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Column(
        key: ValueKey(_paso),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _purple.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_month_rounded,
                        size: 13, color: _purple),
                    const SizedBox(width: 6),
                    const Text('Agendar cita',
                        style: TextStyle(
                            color: _purple,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(titulo,
              style: TextStyle(
                  color: _textDark,
                  fontSize: _small ? 22 : 28,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(sub,
              style: const TextStyle(
                  color: _textGray, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildPasoBar() {
    return PasoIndicator(pasoActual: _paso, pasos: _pasos);
  }

  Widget _buildPasoActual() {
    return switch (_paso) {
      0 => _buildPaso0(),
      1 => _buildPaso1(),
      2 => _buildPaso2(),
      _ => _buildPaso3(),
    };
  }

  // ── Paso 0: Seleccionar terapeuta ──────────────────────────────────────────

  Widget _buildPaso0() {
    return LayoutBuilder(builder: (ctx, constraints) {
      final cols = constraints.maxWidth > 650 ? 2 : 1;
      final gap = 16.0;
      final w = (constraints.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: terapeutasData
            .map((t) => SizedBox(
                  width: w,
                  child: TerapeutaCard(
                    terapeuta: t,
                    seleccionado: _terapeuta?.id == t.id,
                    onSeleccionar: () {
                      setState(() => _terapeuta = t);
                      Future.delayed(const Duration(milliseconds: 300),
                          () => _irA(1));
                    },
                  ),
                ))
            .toList(),
      );
    });
  }

  // ── Paso 1: Calendario ─────────────────────────────────────────────────────

  Widget _buildPaso1() {
    return Column(
      children: [
        // Terapeuta seleccionado (mini card)
        _miniTerapeuta(),
        const SizedBox(height: 24),
        CalendarioWidget(
          fechaSeleccionada: _fecha,
          onSeleccionar: (d) {
            setState(() => _fecha = d);
            Future.delayed(const Duration(milliseconds: 300),
                () => _irA(2));
          },
        ),
        const SizedBox(height: 16),
        _backBtn(() => _irA(0, forward: false)),
      ],
    );
  }

  // ── Paso 2: Horarios ───────────────────────────────────────────────────────

  Widget _buildPaso2() {
    final horarios = horariosParaFecha(_fecha!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _miniTerapeuta(),
        const SizedBox(height: 8),
        _miniFecha(),
        const SizedBox(height: 24),
        // Grid de horarios
        LayoutBuilder(builder: (ctx, constraints) {
          final cols = constraints.maxWidth > 500 ? 3 : 2;
          final gap = 12.0;
          final w = (constraints.maxWidth - gap * (cols - 1)) / cols;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: horarios.map((h) {
              final (label, disponible) = h;
              final sel = _hora == label;
              return SizedBox(
                width: w,
                child: _horarioTile(label, disponible, sel),
              );
            }).toList(),
          );
        }),
        const SizedBox(height: 24),
        if (_hora != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _irA(3),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Confirmar horario',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 17),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        _backBtn(() => _irA(1, forward: false)),
      ],
    );
  }

  Widget _horarioTile(String label, bool disponible, bool sel) {
    return GestureDetector(
      onTap: disponible ? () => setState(() => _hora = label) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: sel
              ? _purple
              : disponible
                  ? Colors.white
                  : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: sel
                ? _purple
                : disponible
                    ? const Color(0xFFEEEBFF)
                    : const Color(0xFFF3F4F6),
            width: sel ? 2 : 1,
          ),
          boxShadow: sel
              ? [
                  BoxShadow(
                      color: _purple.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              disponible ? Icons.access_time_rounded : Icons.block_rounded,
              color: sel
                  ? Colors.white
                  : disponible
                      ? _purple
                      : const Color(0xFFD1D5DB),
              size: 18,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: sel
                    ? Colors.white
                    : disponible
                        ? _textDark
                        : const Color(0xFFD1D5DB),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              disponible ? 'Disponible' : 'Ocupado',
              style: TextStyle(
                color: sel
                    ? Colors.white.withValues(alpha: 0.7)
                    : disponible
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFFD1D5DB),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Paso 3: Confirmación ───────────────────────────────────────────────────

  Widget _buildPaso3() {
    final t = _terapeuta!;
    return Column(
      children: [
        // Success banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [t.gradiente.first, t.gradiente.last],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4), width: 2),
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 34),
              ),
              const SizedBox(height: 16),
              const Text('¡Cita agendada!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                'Recibirás un recordatorio antes de tu sesión.\nEstamos aquí para acompañarte.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                    height: 1.5),
              ),
            ],
          ),
        ),
        // Details card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFEEEBFF)),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(22)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 6))
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              _detalleFila(Icons.person_rounded, 'Terapeuta', t.nombre),
              _divider(),
              _detalleFila(Icons.calendar_today_rounded, 'Fecha',
                  formatearFechaCita(_fecha!)),
              _divider(),
              _detalleFila(Icons.access_time_rounded, 'Hora', _hora!),
              _divider(),
              _detalleFila(Icons.videocam_rounded, 'Modalidad',
                  'Videollamada — 50 minutos'),
              const SizedBox(height: 28),
              // Meet link button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // In production: launch URL
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            '🎥 En producción aquí se abrirá la videollamada'),
                        backgroundColor: t.gradiente.first,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: t.gradiente.first,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.videocam_rounded, size: 20),
                  label: const Text('Ir a videollamada',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 12),
              // meet link text
              Text(
                'meet.google.com/abc-demo-calmaia',
                style: TextStyle(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _irA(0, forward: false),
                child: const Text('Agendar otra cita',
                    style: TextStyle(color: _purple, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detalleFila(IconData icon, String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _purple, size: 18),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(etiqueta,
                  style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(valor,
                  style: const TextStyle(
                      color: _textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
      height: 1, color: const Color(0xFFF3F4F6));

  // ── Shared widgets ─────────────────────────────────────────────────────────

  Widget _miniTerapeuta() {
    final t = _terapeuta!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _softBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEBFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: t.gradiente),
                shape: BoxShape.circle),
            child: Center(
              child: Text(t.iniciales,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.nombre,
                    style: const TextStyle(
                        color: _textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text(t.especialidad,
                    style: const TextStyle(
                        color: _textGray, fontSize: 11)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _irA(0, forward: false),
            child: Text('Cambiar',
                style: TextStyle(
                    color: t.gradiente.first,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _miniFecha() {
    if (_fecha == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _softBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEBFF)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded,
              size: 14, color: _purple),
          const SizedBox(width: 8),
          Text(formatearFechaCita(_fecha!),
              style: const TextStyle(
                  color: _textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          GestureDetector(
            onTap: () => _irA(1, forward: false),
            child: const Text('Cambiar',
                style: TextStyle(
                    color: _purple,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _backBtn(VoidCallback onTap) {
    return TextButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.arrow_back_ios_rounded,
          size: 13, color: Color(0xFF9CA3AF)),
      label: const Text('Volver',
          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
    );
  }
}
