import 'package:flutter/material.dart';
import '../../theme/plat_theme.dart';
import '../../../core/match/match_catalogos.dart';
import '../../../core/match/match_service.dart';
import '../citas/agendar_cita_real_screen.dart';

class EncontrarPsicologoScreen extends StatefulWidget {
  const EncontrarPsicologoScreen({super.key});

  @override
  State<EncontrarPsicologoScreen> createState() =>
      _EncontrarPsicologoScreenState();
}

class _EncontrarPsicologoScreenState extends State<EncontrarPsicologoScreen> {
  int _paso = 0; // 0 área, 1 enfoque, 2 presupuesto, 3 resultados
  String _area = '';
  String _enfoque = ''; // vacío = sin preferencia
  int _presupuesto = 100000;

  bool _buscando = false;
  List<PsicologoMatch> _resultados = [];

  Future<void> _buscar() async {
    setState(() => _buscando = true);
    final res = await MatchService.instance.buscar(
      area: _area,
      enfoque: _enfoque,
      presupuesto: _presupuesto,
    );
    if (!mounted) return;
    setState(() {
      _resultados = res;
      _buscando = false;
      _paso = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlatTheme.softBg,
      appBar: AppBar(
        backgroundColor: PlatTheme.darkNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Encuentra tu psicólogo',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: _paso == 3 ? _resultadosView() : _preguntasView(),
    );
  }

  // ── Preguntas ────────────────────────────────────────────────────────────────
  Widget _preguntasView() {
    return Column(
      children: [
        // Progreso
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Row(
            children: List.generate(3, (i) {
              final activo = i <= _paso;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 5,
                  decoration: BoxDecoration(
                    color: activo ? PlatTheme.purple : const Color(0xFFE8E4FF),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: switch (_paso) {
              1 => _pasoEnfoque(),
              2 => _pasoPresupuesto(),
              _ => _pasoArea(),
            },
          ),
        ),
        // Botones
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              if (_paso > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _paso--),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PlatTheme.purple,
                      side: const BorderSide(color: Color(0xFFE8E4FF)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Atrás'),
                  ),
                ),
              if (_paso > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _puedeAvanzar()
                      ? () {
                          if (_paso < 2) {
                            setState(() => _paso++);
                          } else {
                            _buscar();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PlatTheme.purple,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFD4CAFF),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(_paso < 2 ? 'Continuar' : 'Ver mis matches',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _puedeAvanzar() {
    if (_paso == 0) return _area.isNotEmpty;
    return true; // enfoque y presupuesto siempre tienen valor
  }

  Widget _pasoArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('¿Qué te trae aquí?',
            style: TextStyle(
                color: PlatTheme.textDark,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Elige el tema principal que quieres trabajar.',
            style: TextStyle(color: PlatTheme.textGray, fontSize: 14)),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: areasConsulta
              .map((a) => _chip(a, _area == a, () => setState(() => _area = a)))
              .toList(),
        ),
      ],
    );
  }

  Widget _pasoEnfoque() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('¿Prefieres algún enfoque?',
            style: TextStyle(
                color: PlatTheme.textDark,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Si no sabes, elige "Sin preferencia" — te recomendamos igual.',
            style: TextStyle(color: PlatTheme.textGray, fontSize: 14)),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _chip('Sin preferencia', _enfoque.isEmpty,
                () => setState(() => _enfoque = '')),
            ...enfoquesTerapeuticos.map((e) =>
                _chip(e, _enfoque == e, () => setState(() => _enfoque = e))),
          ],
        ),
      ],
    );
  }

  Widget _pasoPresupuesto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('¿Cuál es tu presupuesto?',
            style: TextStyle(
                color: PlatTheme.textDark,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Por sesión. Te mostramos opciones dentro y cerca de tu rango.',
            style: TextStyle(color: PlatTheme.textGray, fontSize: 14)),
        const SizedBox(height: 26),
        Center(
          child: Text('\$${_fmt(_presupuesto)}',
              style: const TextStyle(
                  color: PlatTheme.purple,
                  fontSize: 34,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        Slider(
          value: _presupuesto.toDouble(),
          min: 30000,
          max: 300000,
          divisions: 27,
          activeColor: PlatTheme.purple,
          onChanged: (v) => setState(() => _presupuesto = v.round()),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$30.000',
                  style: TextStyle(color: PlatTheme.textGray, fontSize: 12)),
              Text('\$300.000',
                  style: TextStyle(color: PlatTheme.textGray, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, bool sel, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: sel ? PlatTheme.purple : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: sel ? PlatTheme.purple : const Color(0xFFE8E4FF)),
        ),
        child: Text(label,
            style: TextStyle(
                color: sel ? Colors.white : PlatTheme.textDark,
                fontSize: 14,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
      ),
    );
  }

  // ── Resultados ───────────────────────────────────────────────────────────────
  Widget _resultadosView() {
    if (_buscando) {
      return const Center(
          child: CircularProgressIndicator(color: PlatTheme.purple));
    }
    if (_resultados.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded,
                  size: 52, color: PlatTheme.textGray.withValues(alpha: 0.4)),
              const SizedBox(height: 14),
              const Text('Aún no hay psicólogos disponibles',
                  style: TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text(
                  'Pronto tendremos profesionales para ti. Vuelve más tarde.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: PlatTheme.textGray, fontSize: 13)),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Tus mejores opciones para "$_area"',
            style: const TextStyle(
                color: PlatTheme.textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Ordenados por compatibilidad contigo.',
            style: TextStyle(color: PlatTheme.textGray, fontSize: 13.5)),
        const SizedBox(height: 18),
        ..._resultados.map(_psicologoCard),
      ],
    );
  }

  Widget _psicologoCard(PsicologoMatch p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEFECFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _avatar(p),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.nombre,
                        style: const TextStyle(
                            color: PlatTheme.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    if (p.enfoque.isNotEmpty)
                      Text(p.enfoque,
                          style: const TextStyle(
                              color: PlatTheme.purple, fontSize: 12.5)),
                  ],
                ),
              ),
              // Match
              Column(
                children: [
                  Text('${p.match}%',
                      style: TextStyle(
                          color: _colorMatch(p.match),
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const Text('match',
                      style: TextStyle(
                          color: PlatTheme.textGray, fontSize: 10)),
                ],
              ),
            ],
          ),
          if (p.bio.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(p.bio,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: PlatTheme.textGray, fontSize: 13, height: 1.4)),
          ],
          if (p.areas.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: p.areas
                  .take(4)
                  .map((a) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF0EEFF),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(a,
                            style: const TextStyle(
                                color: PlatTheme.purple, fontSize: 11)),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFFF2F0FF)),
          const SizedBox(height: 12),
          Row(
            children: [
              if (p.precio > 0) ...[
                const Icon(Icons.payments_rounded,
                    size: 16, color: PlatTheme.textGray),
                const SizedBox(width: 5),
                Text('\$${_fmt(p.precio)} / sesión',
                    style: const TextStyle(
                        color: PlatTheme.textDark,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600)),
              ],
              const Spacer(),
              GestureDetector(
                onTap: () => _elegir(p),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: PlatTheme.purple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Elegir y agendar',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _elegir(PsicologoMatch p) async {
    final err = await MatchService.instance.elegir(p.id);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err), backgroundColor: const Color(0xFFDC2626)));
      return;
    }
    // Asignado → ir a agendar
    await showDialog(
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
            Text('¡${p.nombre} es tu psicólogo!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Ahora agenda tu primera sesión.',
                textAlign: TextAlign.center,
                style: TextStyle(color: PlatTheme.textGray, fontSize: 13.5)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => const AgendarCitaRealScreen()));
            },
            child: const Text('Agendar cita',
                style: TextStyle(color: PlatTheme.purple)),
          ),
        ],
      ),
    );
  }

  Widget _avatar(PsicologoMatch p) {
    if (p.avatarUrl.isNotEmpty) {
      return Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              image: NetworkImage(p.avatarUrl), fit: BoxFit.cover),
        ),
      );
    }
    return Container(
      width: 54,
      height: 54,
      decoration: const BoxDecoration(
          shape: BoxShape.circle, gradient: PlatTheme.purpleGradient),
      child: Center(
        child: Text(p.nombre.isNotEmpty ? p.nombre[0].toUpperCase() : '?',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
      ),
    );
  }

  Color _colorMatch(int m) {
    if (m >= 70) return const Color(0xFF059669);
    if (m >= 45) return const Color(0xFFD97706);
    return PlatTheme.textGray;
  }

  String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
