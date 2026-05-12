import 'package:flutter/material.dart';
import '../theme/plat_theme.dart';
import 'cuestionario_screen.dart';

class BienvenidaScreen extends StatefulWidget {
  const BienvenidaScreen({super.key});

  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.75, curve: Curves.easeOut)),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic)),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: PlatTheme.darkGradient),
        child: SafeArea(
          child: Stack(
            children: [
              _buildRipples(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                child: Column(
                  children: [
                    _buildTopBar(),
                    Expanded(
                      child: FadeTransition(
                        opacity: _fade,
                        child: SlideTransition(
                          position: _slide,
                          child: SingleChildScrollView(
                            child: _buildBody(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white54, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: PlatTheme.purpleGradient),
              child: const Icon(Icons.self_improvement, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text('calma', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const Spacer(),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildRipples() {
    return Center(
      child: Opacity(
        opacity: 0.1,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _circle(520),
            _circle(380),
            _circle(240),
            _circle(110),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
      );

  Widget _buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Central icon with glow rings
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color.fromRGBO(107, 78, 255, 0.3), width: 1),
              ),
            ),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(107, 78, 255, 0.22),
                border: Border.all(color: Color.fromRGBO(107, 78, 255, 0.5), width: 1.5),
              ),
              child: const Icon(Icons.self_improvement, color: Colors.white, size: 52),
            ),
          ],
        ),
        const SizedBox(height: 36),
        const Text(
          'Hola, bienvenido/a.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 46,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const Text(
          'Este es tu espacio de bienestar mental.\nVamos a conocerte un poco mejor para\npersonalizar tu experiencia.',
          style: TextStyle(color: PlatTheme.softBlue, fontSize: 18, height: 1.7),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule_rounded, color: PlatTheme.softBlue, size: 16),
              SizedBox(width: 8),
              Text('Solo toma 3 minutos', style: TextStyle(color: PlatTheme.softBlue, fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: 340,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CuestionarioScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: PlatTheme.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Text(
              'Comenzar mi evaluación',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Tus respuestas son privadas y confidenciales',
          style: TextStyle(color: Color(0xFF8090FF), fontSize: 13),
        ),
      ],
    );
  }
}
