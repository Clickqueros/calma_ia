import 'package:flutter/material.dart';
import '../plataforma/screens/bienvenida_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  static const Color _darkNavy = Color(0xFF0D0A35);
  static const Color _navyPurple = Color(0xFF1A1464);
  static const Color _purple = Color(0xFF6B4EFF);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textGray = Color(0xFF6B7280);
  static const Color _softBlue = Color(0xFFB0BFFF);

  int _selectedProgram = 0;

  bool get _small => MediaQuery.of(context).size.width < 900;
  bool get _xs => MediaQuery.of(context).size.width < 600;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildNavBar(),
            _buildHeroSection(),
            _buildEasyStartSection(),
            _buildProgramSection(),
            _buildMeditationsFeature(),
            _buildSleepFeature(),
            _buildLibrarySection(),
            _buildResultsSection(),
            _buildReviewsSection(),
            _buildCtaSection(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ── NavBar ──────────────────────────────────────────────────────────────────

  Widget _buildNavBar() {
    final pad = _small ? (_xs ? 20.0 : 36.0) : 80.0;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 16),
      child: Row(
        children: [
          _logo(dark: true),
          const Spacer(),
          if (!_small) ...[
            _navLink('Comenzar'),
            const SizedBox(width: 32),
            _navLink('Beneficios'),
            const SizedBox(width: 32),
            _navLink('Testimonios'),
            const SizedBox(width: 40),
          ],
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BienvenidaScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                  horizontal: _small ? 16 : 24, vertical: _small ? 10 : 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text(_small ? 'Comenzar' : 'Iniciar sesión',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _logo({bool dark = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [_purple, _navyPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.self_improvement, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 8),
        Text(
          'calma',
          style: TextStyle(
            color: dark ? _textDark : Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _navLink(String text) {
    return Text(
      text,
      style: const TextStyle(color: _textDark, fontSize: 15, fontWeight: FontWeight.w500),
    );
  }

  // ── Hero ────────────────────────────────────────────────────────────────────

  Widget _buildHeroSection() {
    final pad = _small ? (_xs ? 24.0 : 36.0) : 80.0;
    final titleSize = _xs ? 32.0 : (_small ? 40.0 : 52.0);
    final subtitleSize = _xs ? 15.0 : (_small ? 16.0 : 18.0);

    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Apoyo diario para tu\nsalud mental',
          style: TextStyle(
            color: Colors.white,
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Encuentra calma y bienestar con meditaciones guiadas y el apoyo de nuestra IA.',
          style: TextStyle(color: _softBlue, fontSize: subtitleSize, height: 1.6),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BienvenidaScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: _small ? 24 : 36, vertical: _small ? 14 : 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text('Comenzar gratis',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            if (!_xs)
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white38),
                  padding: EdgeInsets.symmetric(
                      horizontal: _small ? 24 : 36, vertical: _small ? 14 : 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Ver demo', style: TextStyle(fontSize: 15)),
              ),
          ],
        ),
        const SizedBox(height: 36),
        Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            _heroBadge('36M+', 'usuarios'),
            _heroBadge('4.9 ★', 'valoración'),
            _heroBadge('45K+', 'reseñas'),
          ],
        ),
      ],
    );

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_darkNavy, Color(0xFF2D1B69), _navyPurple],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: pad),
      child: _small
          ? textContent
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 5, child: textContent),
                const SizedBox(width: 60),
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 460,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          right: 10,
                          top: 40,
                          child: Transform.rotate(
                            angle: 0.09,
                            child: _phone(width: 175, height: 350),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          top: 20,
                          child: _phone(width: 190, height: 380, showContent: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _heroBadge(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: _softBlue, fontSize: 13)),
      ],
    );
  }

  // ── Phone mockup ────────────────────────────────────────────────────────────

  Widget _phone({
    double width = 180,
    double height = 360,
    List<Color> colors = const [Color(0xFF1E1060), Color(0xFF3B1FA0)],
    bool showContent = false,
  }) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
        border: Border.all(color: _purple, width: 2),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(107, 78, 255, 0.35),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: showContent ? _phoneContent() : null,
    );
  }

  Widget _phoneContent() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _bar(120, 10),
          const SizedBox(height: 8),
          _bar(80, 7, opacity: 0.2),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(107, 78, 255, 0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bar(75, 8),
                      const SizedBox(height: 5),
                      _bar(50, 6, opacity: 0.2),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(double w, double h, {double opacity = 0.3}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, opacity),
        borderRadius: BorderRadius.circular(h / 2),
      ),
    );
  }

  // ── Easy Start ──────────────────────────────────────────────────────────────

  Widget _buildEasyStartSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: _small ? (_xs ? 24 : 36) : 80, vertical: _small ? 48 : 80),
      child: Column(
        children: [
          const Text(
            'Es fácil empezar',
            style: TextStyle(color: _textDark, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tres simples pasos para comenzar tu viaje de bienestar',
            style: TextStyle(color: _textGray, fontSize: 16),
          ),
          const SizedBox(height: 48),
          if (_small)
            Column(
              children: [
                _stepCard('01', Icons.person_outline, 'Crea tu perfil',
                    'Cuéntanos sobre ti y tus objetivos de bienestar para personalizar tu experiencia.'),
                const SizedBox(height: 16),
                _stepCard('02', Icons.explore_outlined, 'Descubre contenido',
                    'Explora meditaciones, artículos y ejercicios diseñados para tus necesidades.'),
                const SizedBox(height: 16),
                _stepCard('03', Icons.trending_up, 'Nota los cambios',
                    'Practica diariamente y sigue tu progreso. Verás resultados en tan solo 12 semanas.'),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _stepCard('01', Icons.person_outline, 'Crea tu perfil',
                    'Cuéntanos sobre ti y tus objetivos de bienestar para personalizar tu experiencia.')),
                const SizedBox(width: 28),
                Expanded(child: _stepCard('02', Icons.explore_outlined, 'Descubre contenido',
                    'Explora meditaciones, artículos y ejercicios diseñados para tus necesidades.')),
                const SizedBox(width: 28),
                Expanded(child: _stepCard('03', Icons.trending_up, 'Nota los cambios',
                    'Practica diariamente y sigue tu progreso. Verás resultados en tan solo 12 semanas.')),
              ],
            ),
        ],
      ),
    );
  }

  Widget _stepCard(String number, IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E4FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [_purple, Color(0xFF9B8FFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const Spacer(),
              Text(
                number,
                style: const TextStyle(
                  color: Color(0xFFD4CAFF),
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(title,
              style: const TextStyle(
                  color: _textDark, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(desc,
              style: const TextStyle(color: _textGray, fontSize: 15, height: 1.6)),
        ],
      ),
    );
  }

  // ── Program Section ─────────────────────────────────────────────────────────

  Widget _buildProgramSection() {
    final tabs = ['Meditaciones', 'Artículos', 'Sonidos', 'Talleres'];
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_darkNavy, _navyPurple, Color(0xFF2D1B69)],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: _small ? (_xs ? 24 : 36) : 80, vertical: _small ? 48 : 80),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Programa transformador de\nconciencia plena',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Un programa completo diseñado por expertos en mindfulness para transformar tu vida día a día.',
                  style: TextStyle(color: _softBlue, fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 40),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: tabs.asMap().entries.map((e) {
                    final selected = _selectedProgram == e.key;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedProgram = e.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? _purple : Colors.white12,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: selected ? _purple : Colors.white24),
                        ),
                        child: Text(e.value,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Más de 500 sesiones disponibles, con nuevas adiciones cada semana. Contenido diseñado para todos los niveles.',
                  style: TextStyle(color: _softBlue, fontSize: 15, height: 1.7),
                ),
              ],
            ),
          ),
          const SizedBox(width: 60),
          Expanded(
            flex: 4,
            child: SizedBox(
              height: 400,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    right: 0,
                    top: 30,
                    child: Transform.rotate(
                      angle: -0.07,
                      child: _phone(
                        width: 165,
                        height: 330,
                        colors: const [Color(0xFF2D1B69), Color(0xFF4C2D9E)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 10,
                    child: _phone(width: 180, height: 360, showContent: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Meditations Feature ─────────────────────────────────────────────────────

  Widget _buildMeditationsFeature() {
    final textCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _chip('Meditaciones'),
        const SizedBox(height: 24),
        Text(
          'Meditaciones diarias y artículos para todos tus deseos',
          style: TextStyle(color: _textDark, fontSize: _small ? 26 : 36, fontWeight: FontWeight.bold, height: 1.2),
        ),
        const SizedBox(height: 20),
        const Text(
          'Desde sesiones de 3 minutos hasta retiros de un día. Meditaciones para reducir el estrés, mejorar el sueño y encontrar paz interior.',
          style: TextStyle(color: _textGray, fontSize: 15, height: 1.7),
        ),
        const SizedBox(height: 32),
        ...['Más de 500 meditaciones guiadas', 'Artículos escritos por expertos',
            'Programas de 30, 60 y 90 días', 'Sesiones para todos los niveles'].map(_checkItem),
      ],
    );
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: _small ? (_xs ? 24 : 36) : 80, vertical: _small ? 48 : 80),
      child: _small
          ? textCol
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 5, child: textCol),
                const SizedBox(width: 80),
                _phone(width: 220, height: 420, colors: const [Color(0xFF1E1060), Color(0xFF4C2D9E), Color(0xFF6B4EFF)], showContent: true),
              ],
            ),
    );
  }

  // ── Sleep Feature ───────────────────────────────────────────────────────────

  Widget _buildSleepFeature() {
    final textCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _chip('Sueño'),
        const SizedBox(height: 24),
        Text(
          'Meditaciones para dormir, historias y sonidos de naturaleza para pasar una buena noche',
          style: TextStyle(color: _textDark, fontSize: _small ? 26 : 36, fontWeight: FontWeight.bold, height: 1.2),
        ),
        const SizedBox(height: 20),
        const Text(
          'Duerme profundamente con nuestra biblioteca de contenido para el descanso. Historias relajantes y meditaciones que te llevarán al sueño que mereces.',
          style: TextStyle(color: _textGray, fontSize: 15, height: 1.7),
        ),
        const SizedBox(height: 32),
        ...['Historias para dormir narradas por expertos', 'Sonidos de lluvia, océano, bosque y más',
            'Meditaciones de relajación progresiva', 'Música binaural para el sueño profundo'].map(_checkItem),
      ],
    );
    return Container(
      color: const Color(0xFFF8F7FF),
      padding: EdgeInsets.symmetric(horizontal: _small ? (_xs ? 24 : 36) : 80, vertical: _small ? 48 : 80),
      child: _small
          ? textCol
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _phone(width: 220, height: 420, colors: const [Color(0xFF0D0A35), Color(0xFF1A1464), Color(0xFF2D1B69)], showContent: true),
                const SizedBox(width: 80),
                Expanded(flex: 5, child: textCol),
              ],
            ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Color.fromRGBO(107, 78, 255, 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(
              color: _purple, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  Widget _checkItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Color.fromRGBO(107, 78, 255, 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 14, color: _purple),
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: _textDark, fontSize: 15)),
        ],
      ),
    );
  }

  // ── Library Section ─────────────────────────────────────────────────────────

  Widget _buildLibrarySection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_darkNavy, _navyPurple],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: _small ? (_xs ? 24 : 36) : 80, vertical: _small ? 48 : 80),
      child: Column(
        children: [
          const Text(
            'La biblioteca más grande en el mundo\nde contenido exclusivo, preparado por expertos',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Miles de horas de contenido premium creado por líderes del mindfulness y el bienestar mental.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _softBlue, fontSize: 16),
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Transform.rotate(
                angle: -0.1,
                child: _phone(
                  width: 155,
                  height: 300,
                  colors: const [Color(0xFF2D1B69), Color(0xFF4C2D9E)],
                ),
              ),
              const SizedBox(width: 20),
              _phone(width: 190, height: 370, showContent: true),
              const SizedBox(width: 20),
              Transform.rotate(
                angle: 0.1,
                child: _phone(
                  width: 155,
                  height: 300,
                  colors: const [Color(0xFF2D1B69), Color(0xFF4C2D9E)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Results Section ─────────────────────────────────────────────────────────

  Widget _buildResultsSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: _small ? (_xs ? 24 : 36) : 80, vertical: _small ? 48 : 80),
      child: Column(
        children: [
          const Text(
            'Resultados reales en tan solo\n12 semanas',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _textDark,
                fontSize: 38,
                fontWeight: FontWeight.bold,
                height: 1.25),
          ),
          const SizedBox(height: 16),
          const Text(
            'Usuarios reportan mejoras significativas después de practicar con calma IA regularmente.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textGray, fontSize: 16),
          ),
          const SizedBox(height: 48),
          if (_small)
            Column(children: [
              _resultCard('42%', 'Reducción del estrés', Icons.favorite_outline, const Color(0xFFFF6B9D)),
              const SizedBox(height: 16),
              _resultCard('60%', 'Mejora en la calidad del sueño', Icons.bedtime_outlined, _purple),
              const SizedBox(height: 16),
              _resultCard('32%', 'Aumento de la concentración', Icons.psychology_outlined, const Color(0xFF00BCD4)),
            ])
          else
            Row(children: [
              Expanded(child: _resultCard('42%', 'Reducción del estrés', Icons.favorite_outline, const Color(0xFFFF6B9D))),
              const SizedBox(width: 24),
              Expanded(child: _resultCard('60%', 'Mejora en la calidad del sueño', Icons.bedtime_outlined, _purple)),
              const SizedBox(width: 24),
              Expanded(child: _resultCard('32%', 'Aumento de la concentración', Icons.psychology_outlined, const Color(0xFF00BCD4))),
            ]),
        ],
      ),
    );
  }

  Widget _resultCard(String stat, String desc, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Color.fromRGBO(color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Color.fromRGBO(color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.15)),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Color.fromRGBO(color.r.toInt(), color.g.toInt(), color.b.toInt(), 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 20),
          Text(stat,
              style: TextStyle(
                  color: color, fontSize: 52, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(desc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textGray, fontSize: 15, height: 1.4)),
        ],
      ),
    );
  }

  // ── Reviews Section ─────────────────────────────────────────────────────────

  Widget _buildReviewsSection() {
    return Container(
      color: const Color(0xFFF8F7FF),
      padding: EdgeInsets.symmetric(horizontal: _small ? (_xs ? 24 : 36) : 80, vertical: _small ? 48 : 80),
      child: Column(
        children: [
          const Text(
            'Más de 45,000 evaluaciones de 5 estrellas',
            style: TextStyle(
                color: _textDark, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ratingBadge('36M+', 'Usuarios activos', Icons.people_outline),
              const SizedBox(width: 80),
              _ratingBadge('4.9', 'Valoración media', Icons.star_rounded),
            ],
          ),
          const SizedBox(height: 48),
          if (_small)
            Column(children: [
              _reviewCard('María García', 'MG', 'Esta app cambió mi vida. Ahora duermo mejor y me siento más tranquila. ¡Las meditaciones son increíbles!'),
              const SizedBox(height: 16),
              _reviewCard('Carlos Rodríguez', 'CR', 'Llevaba años con ansiedad y en solo 8 semanas noté una diferencia enorme. Lo recomiendo totalmente.'),
            ])
          else
            Row(children: [
              Expanded(child: _reviewCard('María García', 'MG', 'Esta app cambió mi vida. Ahora duermo mejor y me siento más tranquila. ¡Las meditaciones son increíbles!')),
              const SizedBox(width: 24),
              Expanded(child: _reviewCard('Carlos Rodríguez', 'CR', 'Llevaba años con ansiedad y en solo 8 semanas noté una diferencia enorme. Lo recomiendo totalmente.')),
              const SizedBox(width: 24),
              Expanded(child: _reviewCard('Ana Martínez', 'AM', 'El contenido es de altísima calidad. Los expertos realmente saben de lo que hablan. Vale cada céntimo.')),
            ]),
        ],
      ),
    );
  }

  Widget _ratingBadge(String value, String label, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _purple, size: 44),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: const TextStyle(
                    color: _textDark,
                    fontSize: 36,
                    fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: _textGray, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _reviewCard(String name, String initials, String review) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (_) => const Icon(Icons.star_rounded,
                  color: Color(0xFFFFB800), size: 20),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '"$review"',
            style: const TextStyle(
              color: _textDark,
              fontSize: 14,
              height: 1.65,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [_purple, Color(0xFF9B8FFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Text(name,
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

  // ── CTA Section ─────────────────────────────────────────────────────────────

  Widget _buildCtaSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_darkNavy, Color(0xFF2D1B69)],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: _small ? (_xs ? 24 : 36) : 80, vertical: _small ? 48 : 80),
      child: Column(
        children: [
          const Text(
            'Hoy te toca a ti.',
            style: TextStyle(
                color: Colors.white, fontSize: 52, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Únete a millones de personas que ya transformaron su bienestar mental con calma IA.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _softBlue, fontSize: 17),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BienvenidaScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 22),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Comenzar gratis ahora',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sin tarjeta de crédito requerida  •  Cancela cuando quieras',
            style: TextStyle(color: Color(0xFF8090FF), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Footer ──────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Container(
      color: const Color(0xFF0A0820),
      padding: EdgeInsets.symmetric(horizontal: _small ? (_xs ? 24 : 36) : 80, vertical: 60),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _logo(),
                    const SizedBox(height: 16),
                    const Text(
                      'Tu compañero de bienestar mental impulsado por inteligencia artificial.',
                      style: TextStyle(color: _textGray, fontSize: 14, height: 1.6),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _storeBtn(Icons.apple, 'App Store'),
                        const SizedBox(width: 12),
                        _storeBtn(Icons.android, 'Google Play'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 60),
              Expanded(
                  flex: 2,
                  child: _footerCol('Producto',
                      ['Meditaciones', 'Artículos', 'Sonidos', 'Talleres'])),
              Expanded(
                  flex: 2,
                  child: _footerCol('Empresa',
                      ['Sobre nosotros', 'Blog', 'Carreras', 'Prensa'])),
              Expanded(
                  flex: 2,
                  child: _footerCol('Soporte',
                      ['Centro de ayuda', 'Contacto', 'Privacidad', 'Términos'])),
            ],
          ),
          const SizedBox(height: 40),
          Container(height: 1, color: Colors.white12),
          const SizedBox(height: 24),
          const Text(
            '© 2024 calma IA. Todos los derechos reservados.',
            style: TextStyle(color: _textGray, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _storeBtn(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _footerCol(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(item,
                  style: const TextStyle(color: _textGray, fontSize: 13)),
            )),
      ],
    );
  }
}
