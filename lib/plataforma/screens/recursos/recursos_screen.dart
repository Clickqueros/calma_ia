import 'package:flutter/material.dart';
import '../../theme/plat_theme.dart';
import 'pdf_helper.dart';

class RecursosScreen extends StatelessWidget {
  const RecursosScreen({super.key});

  static const _sesiones = [
    _Sesion(1, 'SESION 1 -LIBRE DE ANSIEDAD TERAPIA GRUPAL.pdf', '4.1 MB',
        'Introducción al programa y fundamentos de la ansiedad.'),
    _Sesion(2, 'SESION 2 -LIBRE DE ANSIEDAD TERAPIA GRUPAL (1).pdf', '5.5 MB',
        'Identificación de pensamientos automáticos negativos.'),
    _Sesion(3, 'SESION 3 -LIBRE DE ANSIEDAD TERAPIA GRUPAL.pdf', '6.1 MB',
        'Técnicas de respiración y relajación progresiva.'),
    _Sesion(4, 'SESION 4 -LIBRE DE ANSIEDAD TERAPIA GRUPAL.pdf', '4.1 MB',
        'Reestructuración cognitiva y manejo del estrés.'),
    _Sesion(5, 'SESION 5 -LIBRE DE ANSIEDAD TERAPIA GRUPAL.pdf', '7.3 MB',
        'Exposición gradual y enfrentamiento de miedos.'),
    _Sesion(6, 'SESION 6 -LIBRE DE ANSIEDAD TERAPIA GRUPAL.pdf', '6.4 MB',
        'Consolidación y plan de mantenimiento a largo plazo.'),
  ];

  bool _small(BuildContext ctx) => MediaQuery.of(ctx).size.width < 800;

  @override
  Widget build(BuildContext context) {
    final small = _small(context);
    final pad = small ? 20.0 : 48.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 28),
          _buildInfoBanner(),
          const SizedBox(height: 36),
          _buildLabel(),
          const SizedBox(height: 16),
          ..._sesiones.map((s) => _SesionCard(sesion: s, small: small)),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final small = _small(context);

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Color.fromRGBO(107, 78, 255, 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color.fromRGBO(107, 78, 255, 0.2)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open_rounded, size: 14, color: PlatTheme.purple),
          SizedBox(width: 6),
          Text('Programa terapéutico',
              style: TextStyle(
                  color: PlatTheme.purple,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );

    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        badge,
        const SizedBox(height: 16),
        Text(
          'Libre de Ansiedad',
          style: TextStyle(
            color: PlatTheme.textDark,
            fontSize: small ? 24 : 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Material de apoyo para el programa de Terapia Grupal.\nDescarga o abre cada sesión directamente en tu navegador.',
          style: TextStyle(color: PlatTheme.textGray, fontSize: 14, height: 1.6),
        ),
      ],
    );

    final statsBox = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PlatTheme.darkNavy, Color(0xFF2D1B69)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('6',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold)),
          const Text('sesiones',
              style: TextStyle(color: PlatTheme.softBlue, fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Color.fromRGBO(107, 78, 255, 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('PDF',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (small) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [textContent, const SizedBox(height: 16), statsBox],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: textContent),
        const SizedBox(width: 24),
        statsBox,
      ],
    );
  }

  // ── Info banner ────────────────────────────────────────────────────────────

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: PlatTheme.softBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E4FF)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 18, color: PlatTheme.purple),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Sigue el orden de las sesiones para obtener el máximo beneficio del programa.',
              style: TextStyle(
                  color: PlatTheme.textGray, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel() {
    return Row(
      children: [
        const Text('Material del programa',
            style: TextStyle(
                color: PlatTheme.textDark,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Color.fromRGBO(107, 78, 255, 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('6 archivos',
              style: TextStyle(
                  color: PlatTheme.purple,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

// ── Data model ──────────────────────────────────────────────────────────────

class _Sesion {
  final int numero;
  final String filename;
  final String tamano;
  final String descripcion;
  const _Sesion(this.numero, this.filename, this.tamano, this.descripcion);
}

// ── Session card ────────────────────────────────────────────────────────────

class _SesionCard extends StatefulWidget {
  final _Sesion sesion;
  final bool small;
  const _SesionCard({required this.sesion, required this.small});

  @override
  State<_SesionCard> createState() => _SesionCardState();
}

class _SesionCardState extends State<_SesionCard> {
  bool _hovered = false;

  static const _colors = [
    Color(0xFF6B4EFF), Color(0xFF8B5CF6), Color(0xFF7C3AED),
    Color(0xFF6D28D9), Color(0xFF5B21B6), Color(0xFF4C1D95),
  ];

  Color get _accent => _colors[(widget.sesion.numero - 1) % _colors.length];

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered ? _accent : const Color(0xFFE8E4FF),
            width: _hovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? Color.fromRGBO(107, 78, 255, 0.1)
                  : Color.fromRGBO(0, 0, 0, 0.04),
              blurRadius: _hovered ? 20 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: widget.small ? _buildMobile() : _buildDesktop(),
      ),
    );
  }

  Widget _buildDesktop() {
    return IntrinsicHeight(
      child: Row(
        children: [
          _numberCol(),
          Expanded(child: _textContent()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionBtn(
                  icon: Icons.open_in_new_rounded,
                  label: 'Abrir',
                  onTap: () => abrirPDF(widget.sesion.filename),
                  outlined: true,
                  color: _accent,
                ),
                const SizedBox(width: 10),
                _ActionBtn(
                  icon: Icons.download_rounded,
                  label: 'Descargar',
                  onTap: () => descargarPDF(widget.sesion.filename),
                  outlined: false,
                  color: _accent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobile() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _numberBadge(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sesión ${widget.sesion.numero}',
                        style: const TextStyle(
                            color: PlatTheme.textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    Text(widget.sesion.tamano,
                        style: const TextStyle(
                            color: PlatTheme.textGray, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(widget.sesion.descripcion,
              style: const TextStyle(
                  color: PlatTheme.textGray, fontSize: 13, height: 1.4)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  icon: Icons.open_in_new_rounded,
                  label: 'Abrir PDF',
                  onTap: () => abrirPDF(widget.sesion.filename),
                  outlined: true,
                  color: _accent,
                  fullWidth: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionBtn(
                  icon: Icons.download_rounded,
                  label: 'Descargar',
                  onTap: () => descargarPDF(widget.sesion.filename),
                  outlined: false,
                  color: _accent,
                  fullWidth: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _numberCol() {
    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: Color.fromRGBO(
            _accent.r.toInt(), _accent.g.toInt(), _accent.b.toInt(), 0.07),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomLeft: Radius.circular(15),
        ),
        border: const Border(
            right: BorderSide(color: Color(0xFFE8E4FF), width: 1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.sesion.numero.toString().padLeft(2, '0'),
            style: TextStyle(
                color: _accent, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Icon(Icons.picture_as_pdf_rounded, color: _accent, size: 18),
        ],
      ),
    );
  }

  Widget _numberBadge() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Color.fromRGBO(
            _accent.r.toInt(), _accent.g.toInt(), _accent.b.toInt(), 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          widget.sesion.numero.toString().padLeft(2, '0'),
          style: TextStyle(
              color: _accent, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _textContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Sesión ${widget.sesion.numero}',
                  style: const TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: PlatTheme.softBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE8E4FF)),
                ),
                child: Text(widget.sesion.tamano,
                    style: const TextStyle(
                        color: PlatTheme.textGray, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Libre de Ansiedad · Terapia Grupal',
              style: TextStyle(
                  color: _accent, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(widget.sesion.descripcion,
              style: const TextStyle(
                  color: PlatTheme.textGray, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}

// ── Action button ───────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool outlined;
  final Color color;
  final bool fullWidth;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.outlined,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: outlined ? color : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: outlined ? color : Colors.white),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: outlined ? color : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
