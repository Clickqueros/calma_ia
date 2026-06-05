import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import '../data/demo_data.dart';

class PacienteDetalleScreen extends StatefulWidget {
  final PacienteDemo paciente;
  const PacienteDetalleScreen({super.key, required this.paciente});

  @override
  State<PacienteDetalleScreen> createState() => _PacienteDetalleScreenState();
}

class _PacienteDetalleScreenState extends State<PacienteDetalleScreen> {
  int _tab = 0;
  static const _tabs = ['Resumen', 'Historia clínica', 'Sesiones', 'Tareas', 'Emocional'];

  bool get _small => MediaQuery.of(context).size.width < 900;

  PacienteDemo get p => widget.paciente;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlatTheme.softBg,
      appBar: AppBar(
        backgroundColor: PlatTheme.darkNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Perfil del paciente',
            style: TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(_small ? 18 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cabecera(),
            const SizedBox(height: 20),
            _tabBar(),
            const SizedBox(height: 20),
            _contenido(),
          ],
        ),
      ),
    );
  }

  // ── Cabecera ─────────────────────────────────────────────────────────────

  Widget _cabecera() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PlatTheme.darkNavy, Color(0xFF2D1B69)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: p.gradiente),
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: Center(
              child: Text(p.iniciales,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.nombre,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${p.edad} años · ${p.sesionesCompletadas} sesiones',
                    style: const TextStyle(
                        color: PlatTheme.softBlue, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: p.estado.color.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(p.estado.label,
                      style: TextStyle(
                          color: _lighten(p.estado.color),
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _lighten(Color c) => Color.lerp(c, Colors.white, 0.5)!;

  // ── Tabs ─────────────────────────────────────────────────────────────────

  Widget _tabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _tabs.asMap().entries.map((e) {
          final sel = _tab == e.key;
          return GestureDetector(
            onTap: () => setState(() => _tab = e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: sel ? PlatTheme.purple : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: sel ? PlatTheme.purple : const Color(0xFFE8E4FF)),
              ),
              child: Text(e.value,
                  style: TextStyle(
                      color: sel ? Colors.white : PlatTheme.textGray,
                      fontSize: 13,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w500)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _contenido() => switch (_tab) {
        1 => _historiaClinica(),
        2 => _sesiones(),
        3 => _tareas(),
        4 => _emocional(),
        _ => _resumen(),
      };

  // ── Tab: Resumen ─────────────────────────────────────────────────────────

  Widget _resumen() {
    return Column(
      children: [
        _card(
          titulo: 'Datos de contacto',
          child: Column(
            children: [
              _dato(Icons.phone_rounded, 'Teléfono', p.telefono),
              _dato(Icons.email_rounded, 'Email', p.email),
              _dato(Icons.cake_rounded, 'Edad', '${p.edad} años'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _card(
          titulo: 'Motivo de consulta',
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(p.motivoConsulta,
                style: const TextStyle(
                    color: PlatTheme.textDark, fontSize: 14, height: 1.5)),
          ),
        ),
        const SizedBox(height: 16),
        _card(
          titulo: 'Estado del proceso',
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: p.estado.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(p.estado.label,
                    style: TextStyle(
                        color: p.estado.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              if (p.proximaCita != null)
                Text('Próxima: ${p.proximaCita}',
                    style: const TextStyle(
                        color: PlatTheme.purple,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dato(IconData icon, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: PlatTheme.purple),
          const SizedBox(width: 12),
          Text('$label:',
              style: const TextStyle(color: PlatTheme.textGray, fontSize: 13)),
          const Spacer(),
          Text(valor,
              style: const TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Tab: Historia clínica ──────────────────────────────────────────────────

  Widget _historiaClinica() {
    return Column(
      children: [
        _bannerPrivado(),
        const SizedBox(height: 16),
        _card(
          titulo: 'Antecedentes',
          accion: 'Editar',
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
                'Sin antecedentes médicos ni psiquiátricos relevantes. Primer proceso terapéutico. Refiere episodios de estrés laboral desde hace 8 meses.',
                style: TextStyle(
                    color: PlatTheme.textDark, fontSize: 14, height: 1.5)),
          ),
        ),
        const SizedBox(height: 16),
        _card(
          titulo: 'Impresión diagnóstica',
          accion: 'Editar',
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
                'Trastorno de ansiedad generalizada (F41.1). En seguimiento con técnicas de TCC.',
                style: TextStyle(
                    color: PlatTheme.textDark, fontSize: 14, height: 1.5)),
          ),
        ),
        const SizedBox(height: 16),
        _card(
          titulo: 'Documentos adjuntos',
          accion: 'Adjuntar',
          child: Column(
            children: [
              _docRow('Consentimiento informado.pdf', 'Aceptado 12 mar 2026'),
              _docRow('Evaluación inicial.pdf', 'Adjuntado 14 mar 2026'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: _btnPrimario(Icons.picture_as_pdf_rounded, 'Exportar historia en PDF'),
        ),
      ],
    );
  }

  Widget _docRow(String nombre, String fecha) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PlatTheme.softBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_rounded,
              color: PlatTheme.purple, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre,
                    style: const TextStyle(
                        color: PlatTheme.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text(fecha,
                    style: const TextStyle(
                        color: PlatTheme.textGray, fontSize: 11.5)),
              ],
            ),
          ),
          const Icon(Icons.download_rounded,
              color: PlatTheme.textGray, size: 18),
        ],
      ),
    );
  }

  // ── Tab: Sesiones ──────────────────────────────────────────────────────────

  Widget _sesiones() {
    final sesiones = [
      ('Sesión 8', 'Hace 2 días', 'Reestructuración cognitiva',
          'Se trabajó identificación de pensamientos catastróficos. Paciente muestra avances en técnicas de respiración.'),
      ('Sesión 7', 'Hace 9 días', 'Manejo de ansiedad',
          'Práctica de exposición interoceptiva. Se asignó registro de pensamientos automáticos.'),
      ('Sesión 6', 'Hace 16 días', 'Psicoeducación',
          'Explicación del ciclo de la ansiedad. Buen entendimiento. Compromiso: diario emocional diario.'),
    ];
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: _btnPrimario(Icons.add_rounded, 'Registrar nueva sesión'),
        ),
        const SizedBox(height: 16),
        ...sesiones.map((s) => _card(
              titulo: s.$1,
              accion: s.$2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF0EEFF),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(s.$3,
                        style: const TextStyle(
                            color: PlatTheme.purple,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 10),
                  Text(s.$4,
                      style: const TextStyle(
                          color: PlatTheme.textDark,
                          fontSize: 13.5,
                          height: 1.5)),
                ],
              ),
            )),
      ],
    );
  }

  // ── Tab: Tareas ────────────────────────────────────────────────────────────

  Widget _tareas() {
    final tareas = tareasDemo
        .where((t) => t.pacienteNombre == p.nombre)
        .toList();
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: _btnPrimario(Icons.add_task_rounded, 'Asignar tarea terapéutica'),
        ),
        const SizedBox(height: 16),
        if (tareas.isEmpty)
          _card(
            titulo: 'Tareas asignadas',
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text('Este paciente aún no tiene tareas asignadas.',
                  style: TextStyle(color: PlatTheme.textGray, fontSize: 13)),
            ),
          )
        else
          ...tareas.map((t) => _card(
                child: Row(
                  children: [
                    Icon(
                      t.completada
                          ? Icons.check_circle_rounded
                          : Icons.pending_rounded,
                      color: t.completada
                          ? const Color(0xFF059669)
                          : const Color(0xFFD97706),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.titulo,
                              style: const TextStyle(
                                  color: PlatTheme.textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          Text(t.completada
                              ? 'Completada · toca para revisar'
                              : t.fechaLimite,
                              style: const TextStyle(
                                  color: PlatTheme.textGray, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  // ── Tab: Emocional ──────────────────────────────────────────────────────────

  Widget _emocional() {
    final registros = [
      ('Hoy', p.ultimoEstado, p.nivelBienestar),
      ('Ayer', '😌 Tranquila', 68),
      ('Hace 2 días', '😰 Ansiosa', 52),
      ('Hace 3 días', '😮‍💨 Cansada', 58),
      ('Hace 4 días', '🌱 Esperanzada', 70),
    ];
    return Column(
      children: [
        _card(
          titulo: 'Bienestar general',
          child: Row(
            children: [
              Text('${p.nivelBienestar}%',
                  style: TextStyle(
                      color: _colorNivel(p.nivelBienestar),
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                    'Promedio basado en los registros del diario emocional del paciente.',
                    style:
                        TextStyle(color: PlatTheme.textGray, fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _card(
          titulo: 'Historial del diario',
          child: Column(
            children: registros
                .map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(r.$1,
                                style: const TextStyle(
                                    color: PlatTheme.textGray, fontSize: 12.5)),
                          ),
                          Expanded(
                            child: Text(r.$2,
                                style: const TextStyle(
                                    color: PlatTheme.textDark,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500)),
                          ),
                          Text('${r.$3}%',
                              style: TextStyle(
                                  color: _colorNivel(r.$3),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Color _colorNivel(int n) {
    if (n >= 65) return const Color(0xFF059669);
    if (n >= 50) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _bannerPrivado() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCD9A8)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_rounded, color: Color(0xFFD97706), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
                'Información clínica privada. El paciente no puede ver este contenido.',
                style: TextStyle(
                    color: Color(0xFF92400E),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _card({String? titulo, String? accion, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFECFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titulo != null) ...[
            Row(
              children: [
                Text(titulo,
                    style: const TextStyle(
                        color: PlatTheme.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                if (accion != null)
                  Text(accion,
                      style: const TextStyle(
                          color: PlatTheme.purple,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _btnPrimario(IconData icon, String label) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label (demo)'),
            backgroundColor: PlatTheme.darkNavy,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: PlatTheme.purple,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 19),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
