import 'package:flutter/material.dart';
import 'models/nota_model.dart';
import 'services/diario_service.dart';
import 'widgets/estado_selector.dart';
import 'widgets/nota_card.dart';

class DiarioScreen extends StatefulWidget {
  const DiarioScreen({super.key});

  @override
  State<DiarioScreen> createState() => _DiarioScreenState();
}

class _DiarioScreenState extends State<DiarioScreen> {
  final _tituloCtrl = TextEditingController();
  final _contenidoCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  EstadoEmocional? _estado;
  bool _guardando = false;
  bool _guardado = false;
  NotaDiario? _notaVista;

  static const _purple = Color(0xFF6B4EFF);
  static const _textDark = Color(0xFF1A1A2E);
  static const _textGray = Color(0xFF6B7280);
  static const _softBg = Color(0xFFF8F7FF);

  bool get _small => MediaQuery.of(context).size.width < 800;

  @override
  void initState() {
    super.initState();
    DiarioService.instance.addListener(_onServiceChange);
  }

  void _onServiceChange() => setState(() {});

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _contenidoCtrl.dispose();
    _scrollCtrl.dispose();
    DiarioService.instance.removeListener(_onServiceChange);
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_notaVista != null) return _buildVistaCompleta(_notaVista!);

    final pad = _small ? 20.0 : 48.0;
    return SingleChildScrollView(
      controller: _scrollCtrl,
      padding: EdgeInsets.all(pad),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 28),
            _buildEditor(),
            const SizedBox(height: 40),
            _buildListaNotas(),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
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
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('📔', style: TextStyle(fontSize: 13)),
                  SizedBox(width: 6),
                  Text('Diario emocional',
                      style: TextStyle(
                          color: _purple,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Mis notas',
          style: TextStyle(
              color: _textDark, fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Escribe lo que sientes, sin juicio y a tu ritmo.',
          style: TextStyle(color: _textGray, fontSize: 15, height: 1.5),
        ),
      ],
    );
  }

  // ── Editor ────────────────────────────────────────────────────────────────

  Widget _buildEditor() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: _guardado ? _buildConfirmacion() : _buildFormulario(),
    );
  }

  Widget _buildFormulario() {
    return Container(
      key: const ValueKey('form'),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEEEBFF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Micro-copy emocional
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Text('✨', style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No tienes que escribir perfecto. Solo escribe lo que necesitas soltar.',
                    style: TextStyle(
                        color: Color(0xFF5B21B6),
                        fontSize: 13,
                        height: 1.45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Estado emocional
          const Text('¿Cómo te sientes hoy?',
              style: TextStyle(
                  color: _textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          EstadoSelector(
            seleccionado: _estado,
            onSeleccionar: (e) => setState(() => _estado = e),
          ),
          const SizedBox(height: 24),

          // Título (opcional)
          TextField(
            controller: _tituloCtrl,
            style: const TextStyle(
                color: _textDark, fontSize: 15, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Título de tu nota (opcional)',
              hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
              filled: true,
              fillColor: _softBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 14),

          // Contenido principal
          TextField(
            controller: _contenidoCtrl,
            maxLines: null,
            minLines: 6,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(
                color: _textDark, fontSize: 15, height: 1.65),
            decoration: InputDecoration(
              hintText:
                  'Escribe aquí tus pensamientos, emociones, síntomas o cualquier reflexión de tu día...',
              hintStyle: const TextStyle(
                  color: Color(0xFFD1D5DB), height: 1.65),
              filled: true,
              fillColor: _softBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _purple, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Todo lo que escribas es privado y solo tuyo.',
            style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 11),
          ),
          const SizedBox(height: 24),

          // Guardar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _guardando ? null : _guardarNota,
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _purple.withValues(alpha: 0.5),
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
                          color: Colors.white, strokeWidth: 2))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_add_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Guardar nota',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmacion() {
    return Container(
      key: const ValueKey('ok'),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD1FAE5)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFD1FAE5),
            ),
            child: const Icon(Icons.check_rounded,
                color: Color(0xFF059669), size: 34),
          ),
          const SizedBox(height: 20),
          const Text('¡Nota guardada!',
              style: TextStyle(
                  color: _textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Gracias por tomarte este espacio.\nCada nota es un paso en tu camino.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textGray, fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => setState(() => _guardado = false),
            style: OutlinedButton.styleFrom(
              foregroundColor: _purple,
              side: const BorderSide(color: _purple),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Escribir otra nota',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Notes list ────────────────────────────────────────────────────────────

  Widget _buildListaNotas() {
    final notas = DiarioService.instance.notas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Mis notas anteriores',
                style: TextStyle(
                    color: _textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            if (notas.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${notas.length}',
                    style: const TextStyle(
                        color: _purple,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
          ],
        ),
        const SizedBox(height: 20),
        if (notas.isEmpty)
          _buildEmptyState()
        else
          ...notas.map((n) => NotaCard(
                nota: n,
                onEliminar: () => DiarioService.instance.eliminar(n.id),
                onVer: () => setState(() => _notaVista = n),
              )),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDE9FE)),
      ),
      child: const Column(
        children: [
          Text('📔', style: TextStyle(fontSize: 48)),
          SizedBox(height: 16),
          Text('Tu diario está vacío',
              style: TextStyle(
                  color: _textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(
            'Escribe tu primera nota arriba.\nNo tiene que ser perfecta — solo honesta.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textGray, fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }

  // ── Vista completa de nota ────────────────────────────────────────────────

  Widget _buildVistaCompleta(NotaDiario nota) {
    final pad = _small ? 20.0 : 48.0;
    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            GestureDetector(
              onTap: () => setState(() => _notaVista = null),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEEEBFF)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios_rounded,
                        size: 14, color: _textGray),
                    SizedBox(width: 4),
                    Text('Volver al diario',
                        style: TextStyle(color: _textGray, fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Note content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: nota.estado.color.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 6))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: nota.estado.bgSuave,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: nota.estado.color.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(nota.estado.emoji,
                                style: const TextStyle(fontSize: 15)),
                            const SizedBox(width: 6),
                            Text(nota.estado.label,
                                style: TextStyle(
                                    color: nota.estado.color,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${formatearFecha(nota.fecha)} · ${formatearHora(nota.fecha)}',
                        style: const TextStyle(
                            color: Color(0xFF9CA3AF), fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (nota.titulo.isNotEmpty) ...[
                    Text(nota.titulo,
                        style: const TextStyle(
                            color: _textDark,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.2)),
                    const SizedBox(height: 16),
                    Container(
                        height: 1,
                        color: const Color(0xFFF3F4F6)),
                    const SizedBox(height: 16),
                  ],
                  Text(nota.contenido,
                      style: const TextStyle(
                          color: Color(0xFF374151),
                          fontSize: 15,
                          height: 1.75)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _guardarNota() async {
    final contenido = _contenidoCtrl.text.trim();
    if (contenido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Escribe algo antes de guardar 💙'),
          backgroundColor: const Color(0xFF6B4EFF),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _guardando = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final nota = NotaDiario(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloCtrl.text.trim(),
      contenido: contenido,
      estado: _estado ?? EstadoEmocional.tranquilo,
      fecha: DateTime.now(),
    );

    DiarioService.instance.agregar(nota);

    _tituloCtrl.clear();
    _contenidoCtrl.clear();
    setState(() {
      _guardando = false;
      _guardado = true;
      _estado = null;
    });
  }
}
