import 'package:flutter/material.dart';
import '../../theme/plat_theme.dart';
import 'lotus_painter.dart';
import 'breath_audio.dart';

// ── Fase model ──────────────────────────────────────────────────────────────

enum _Fase { inhala, mantiene, exhala }

extension _FaseExt on _Fase {
  String get label => switch (this) {
        _Fase.inhala => 'Inhala',
        _Fase.mantiene => 'Mantén',
        _Fase.exhala => 'Exhala',
      };

  IconData get icon => switch (this) {
        _Fase.inhala => Icons.arrow_upward_rounded,
        _Fase.mantiene => Icons.pause_rounded,
        _Fase.exhala => Icons.arrow_downward_rounded,
      };

  int get seconds => switch (this) {
        _Fase.inhala => 4,
        _Fase.mantiene => 7,
        _Fase.exhala => 8,
      };
}

// ── Screen ──────────────────────────────────────────────────────────────────

class RespiracionScreen extends StatefulWidget {
  const RespiracionScreen({super.key});

  @override
  State<RespiracionScreen> createState() => _RespiracionScreenState();
}

class _RespiracionScreenState extends State<RespiracionScreen>
    with TickerProviderStateMixin {
  // 4 - 7 - 8  breathing
  static const _inhala = 4;
  static const _mantiene = 7;
  static const _exhala = 8;
  static const _total = _inhala + _mantiene + _exhala; // 19 s

  late final AnimationController _cycleCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _glowAnim;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  late final AnimationController _fadeCtrl;

  _Fase _fase = _Fase.inhala;
  int _segsLeft = _inhala;
  int _ciclo = 1;
  bool _playing = false;
  bool _sonido = true;

  @override
  void initState() {
    super.initState();

    // Main breathing cycle — exact 4-7-8 timing via TweenSequence weights
    _cycleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _total),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.42, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: _inhala.toDouble(),
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: _mantiene.toDouble(),
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.42)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: _exhala.toDouble(),
      ),
    ]).animate(_cycleCtrl);

    _glowAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.25, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: _inhala.toDouble(),
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: _mantiene.toDouble(),
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.25)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: _exhala.toDouble(),
      ),
    ]).animate(_cycleCtrl);

    // Subtle pulse during mantén
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: -0.015, end: 0.015)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Entrance fade
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _cycleCtrl.addListener(_syncPhase);
    _cycleCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() => _ciclo++);
        _cycleCtrl.forward(from: 0);
      }
    });

    // Pre-initialize audio engine (starts silent, no user gesture needed yet)
    initAudio();
  }

  void _syncPhase() {
    final t = _cycleCtrl.value * _total;

    _Fase newFase;
    int newSegs;

    if (t < _inhala) {
      newFase = _Fase.inhala;
      newSegs = (_inhala - t).ceil().clamp(1, _inhala);
    } else if (t < _inhala + _mantiene) {
      newFase = _Fase.mantiene;
      newSegs = (_inhala + _mantiene - t).ceil().clamp(1, _mantiene);
    } else {
      newFase = _Fase.exhala;
      newSegs = (_total - t).ceil().clamp(1, _exhala);
    }

    if (newFase != _fase) {
      _onFaseChange(newFase);
    }

    if (newFase != _fase || newSegs != _segsLeft) {
      setState(() {
        _fase = newFase;
        _segsLeft = newSegs;
      });
    }
  }

  // Trigger audio ramp on every phase change
  void _onFaseChange(_Fase newFase) {
    if (!_sonido) return;
    switch (newFase) {
      case _Fase.inhala:
        // Cuenco sube suavemente durante la inhalación (4 s)
        rampGain(0.30, _inhala.toDouble());
      case _Fase.mantiene:
        // Se sostiene en el pico — estable (el cap en 0.06 lo controla)
        rampGain(0.30, 0.5);
      case _Fase.exhala:
        // Cuenco desvanece lentamente durante la exhalación (8 s)
        rampGain(0.02, _exhala.toDouble());
    }
  }

  void _togglePlay() {
    setState(() {
      if (_playing) {
        _cycleCtrl.stop();
        stopAudio();
      } else {
        // Start audio engine on first user gesture (browser policy)
        startAudio();
        _cycleCtrl.forward();
        // Trigger audio for the current phase immediately
        _onFaseChange(_fase);
      }
      _playing = !_playing;
    });
  }

  @override
  void dispose() {
    _cycleCtrl.dispose();
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    disposeAudio();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final small = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeCtrl,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF14082E),
                Color(0xFF2D1B69),
                Color(0xFF1A1464),
                Color(0xFF0D0A35),
              ],
              stops: [0.0, 0.35, 0.70, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildTagline(),
                Expanded(child: _buildLotus(small)),
                _buildFaseCards(small),
                _buildControls(context, small),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          _glassBtn(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white70, size: 16),
          ),
          Expanded(
            child: Column(
              children: [
                const Text('Respiración',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(
                  'Ciclo $_ciclo  ·  4 - 7 - 8',
                  style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 0.45),
                      fontSize: 12),
                ),
              ],
            ),
          ),
          _glassBtn(
            child: const Icon(Icons.self_improvement,
                color: Colors.white70, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _glassBtn({VoidCallback? onTap, required Widget child}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.10),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Color.fromRGBO(255, 255, 255, 0.12)),
        ),
        child: child,
      ),
    );
  }

  // ── Tagline ───────────────────────────────────────────────────────────────

  Widget _buildTagline() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color.fromRGBO(255, 255, 255, 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.air_rounded,
              size: 13, color: Color.fromRGBO(255, 255, 255, 0.55)),
          const SizedBox(width: 7),
          Text(
            'Encuentra tu ritmo. Respira consciente.',
            style: TextStyle(
                color: Color.fromRGBO(255, 255, 255, 0.60),
                fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Central lotus element ─────────────────────────────────────────────────

  Widget _buildLotus(bool small) {
    final size = small ? 270.0 : 340.0;
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_cycleCtrl, _pulseCtrl]),
        builder: (context, _) {
          var s = _scaleAnim.value;
          if (_fase == _Fase.mantiene) s += _pulseAnim.value;
          final g = _glowAnim.value;

          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer ambient glow layers
              _glowRing(size * s * 1.38, Color.fromRGBO(124, 111, 255, 0.04 * g)),
              _glowRing(size * s * 1.20, Color.fromRGBO(124, 111, 255, 0.07 * g)),
              _glowRing(size * s * 1.05, Color.fromRGBO(155, 143, 255, 0.10 * g)),

              // Lotus CustomPainter
              CustomPaint(
                size: Size(size, size),
                painter: LotusPainter(scale: s, glow: g),
              ),

              // Phase text
              _buildPhaseText(),
            ],
          );
        },
      ),
    );
  }

  Widget _glowRing(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 40, spreadRadius: 10),
        ],
      ),
    );
  }

  Widget _buildPhaseText() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                      begin: const Offset(0, 0.15), end: Offset.zero)
                  .animate(anim),
              child: child,
            ),
          ),
          child: Text(
            _fase.label,
            key: ValueKey(_fase),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w300,
              letterSpacing: 4,
            ),
          ),
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            '$_segsLeft',
            key: ValueKey(_segsLeft),
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.75),
              fontSize: 22,
              fontWeight: FontWeight.w200,
            ),
          ),
        ),
        Text(
          'seg',
          style: TextStyle(
            color: Color.fromRGBO(255, 255, 255, 0.35),
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  // ── Phase cards ───────────────────────────────────────────────────────────

  Widget _buildFaseCards(bool small) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 16 : 40, vertical: 12),
      child: Row(
        children: _Fase.values
            .map((f) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: f != _Fase.exhala ? 10 : 0),
                    child: _faseCard(f),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _faseCard(_Fase f) {
    final active = _playing && _fase == f;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: active
            ? Color.fromRGBO(155, 143, 255, 0.22)
            : Color.fromRGBO(255, 255, 255, 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active
              ? Color.fromRGBO(255, 255, 255, 0.35)
              : Color.fromRGBO(255, 255, 255, 0.09),
        ),
        boxShadow: active
            ? [
                BoxShadow(
                    color: Color.fromRGBO(124, 111, 255, 0.25),
                    blurRadius: 16)
              ]
            : [],
      ),
      child: Column(
        children: [
          Icon(f.icon,
              size: 17,
              color: active
                  ? Colors.white
                  : Color.fromRGBO(255, 255, 255, 0.35)),
          const SizedBox(height: 6),
          Text(f.label,
              style: TextStyle(
                  color: active
                      ? Colors.white
                      : Color.fromRGBO(255, 255, 255, 0.45),
                  fontSize: 12,
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.w400)),
          const SizedBox(height: 2),
          Text('${f.seconds} seg',
              style: TextStyle(
                  color: active
                      ? Color.fromRGBO(255, 255, 255, 0.75)
                      : Color.fromRGBO(255, 255, 255, 0.25),
                  fontSize: 11)),
        ],
      ),
    );
  }

  // ── Controls ──────────────────────────────────────────────────────────────

  Widget _buildControls(BuildContext context, bool small) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          small ? 16 : 40, 4, small ? 16 : 40, 24),
      child: Row(
        children: [
          // Sound toggle
          GestureDetector(
            onTap: () {
              setState(() => _sonido = !_sonido);
              if (_sonido && _playing) {
                _onFaseChange(_fase); // reactivar con el volumen de la fase actual
              } else {
                stopAudio();
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Color.fromRGBO(255, 255, 255, 0.10)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _sonido
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    color: _sonido
                        ? Colors.white
                        : Color.fromRGBO(255, 255, 255, 0.35),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _sonido ? 'Sonido' : 'Mudo',
                    style: TextStyle(
                        color: _sonido
                            ? Color.fromRGBO(255, 255, 255, 0.80)
                            : Color.fromRGBO(255, 255, 255, 0.35),
                        fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Play / Pause
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [PlatTheme.purple, PlatTheme.softPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(107, 78, 255, 0.55),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),

          const Spacer(),

          // Finish
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Color.fromRGBO(255, 255, 255, 0.10)),
              ),
              child: Text(
                small ? 'Finalizar' : 'Finalizar sesión',
                style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 0.65),
                    fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
