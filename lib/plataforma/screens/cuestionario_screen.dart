import 'package:flutter/material.dart';
import '../theme/plat_theme.dart';
import '../models/pregunta.dart';
import '../widgets/opcion_card.dart';
import '../widgets/progreso_bar.dart';
import 'dashboard_screen.dart';

class CuestionarioScreen extends StatefulWidget {
  const CuestionarioScreen({super.key});

  @override
  State<CuestionarioScreen> createState() => _CuestionarioScreenState();
}

class _CuestionarioScreenState extends State<CuestionarioScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  late final List<Set<int>> _respuestas;
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _respuestas = List.generate(preguntas.length, (_) => {});
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _siguiente() {
    if (_step < preguntas.length - 1) {
      _ctrl.reverse().then((_) {
        setState(() => _step++);
        _ctrl.forward();
      });
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondary) => const DashboardScreen(),
          transitionsBuilder: (context, anim, secondary, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _anterior() {
    if (_step > 0) {
      _ctrl.reverse().then((_) {
        setState(() => _step--);
        _ctrl.forward();
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _toggle(int idx) {
    setState(() {
      final p = preguntas[_step];
      if (p.multiSelect) {
        _respuestas[_step].contains(idx)
            ? _respuestas[_step].remove(idx)
            : _respuestas[_step].add(idx);
      } else {
        _respuestas[_step] = {idx};
      }
    });
  }

  bool get _puedeAvanzar => _respuestas[_step].isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlatTheme.softBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: _buildContenido(),
                    ),
                  ),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 20),
      child: Column(
        children: [
          Row(
            children: [
              _backBtn(),
              const Spacer(),
              _logoSmall(),
              const Spacer(),
              const SizedBox(width: 42),
            ],
          ),
          const SizedBox(height: 20),
          ProgresoBar(currentStep: _step, totalSteps: preguntas.length),
        ],
      ),
    );
  }

  Widget _backBtn() {
    return GestureDetector(
      onTap: _anterior,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: PlatTheme.softBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE8E4FF)),
        ),
        child: const Icon(Icons.arrow_back_ios_rounded, size: 16, color: PlatTheme.textGray),
      ),
    );
  }

  Widget _logoSmall() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(shape: BoxShape.circle, gradient: PlatTheme.purpleGradient),
          child: const Icon(Icons.self_improvement, color: Colors.white, size: 15),
        ),
        const SizedBox(width: 8),
        const Text('calma',
            style: TextStyle(color: PlatTheme.textDark, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ── Question content ───────────────────────────────────────────────────────

  Widget _buildContenido() {
    final pregunta = preguntas[_step];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 44),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(pregunta.emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 24),
          Text(
            pregunta.titulo,
            style: const TextStyle(
              color: PlatTheme.textDark,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.35,
            ),
          ),
          if (pregunta.descripcion != null) ...[
            const SizedBox(height: 10),
            Text(pregunta.descripcion!,
                style: const TextStyle(color: PlatTheme.textGray, fontSize: 15, height: 1.5)),
          ],
          const SizedBox(height: 36),
          pregunta.multiSelect ? _multiSelectGrid(pregunta) : _singleSelectList(pregunta),
        ],
      ),
    );
  }

  Widget _singleSelectList(Pregunta p) {
    return Column(
      children: p.opciones.asMap().entries.map((e) => OpcionCard(
            texto: e.value,
            seleccionada: _respuestas[_step].contains(e.key),
            onTap: () => _toggle(e.key),
          )).toList(),
    );
  }

  Widget _multiSelectGrid(Pregunta p) {
    return Wrap(
      spacing: 12,
      runSpacing: 0,
      children: p.opciones.asMap().entries.map((e) => SizedBox(
            width: 310,
            child: OpcionCard(
              texto: e.value,
              seleccionada: _respuestas[_step].contains(e.key),
              onTap: () => _toggle(e.key),
            ),
          )).toList(),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    final esUltimo = _step == preguntas.length - 1;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        children: [
          if (_step > 0)
            TextButton(
              onPressed: _anterior,
              style: TextButton.styleFrom(
                foregroundColor: PlatTheme.textGray,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: const Text('Anterior', style: TextStyle(fontSize: 15)),
            ),
          const Spacer(),
          AnimatedOpacity(
            opacity: _puedeAvanzar ? 1.0 : 0.35,
            duration: const Duration(milliseconds: 200),
            child: ElevatedButton(
              onPressed: _puedeAvanzar ? _siguiente : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: PlatTheme.purple,
                disabledBackgroundColor: PlatTheme.purple,
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    esUltimo ? 'Ver mi espacio' : 'Continuar',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
