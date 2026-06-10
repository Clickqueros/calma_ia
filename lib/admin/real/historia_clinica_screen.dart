import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import '../../core/auth/perfil_service.dart';
import '../../core/clinica/historia_service.dart';
import '../../core/clinica/diagnosticos.dart';

class HistoriaClinicaScreen extends StatefulWidget {
  final PacienteVinculado paciente;
  const HistoriaClinicaScreen({super.key, required this.paciente});

  @override
  State<HistoriaClinicaScreen> createState() => _HistoriaClinicaScreenState();
}

class _HistoriaClinicaScreenState extends State<HistoriaClinicaScreen> {
  final _motivo = TextEditingController();
  final _antecedentes = TextEditingController();
  final _observaciones = TextEditingController();
  String _diagCodigo = '';
  String _diagNombre = '';

  List<Evolucion> _evoluciones = [];
  bool _cargando = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _motivo.dispose();
    _antecedentes.dispose();
    _observaciones.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final h = await HistoriaService.instance.obtener(widget.paciente.id);
    final evo = await HistoriaService.instance.evoluciones(widget.paciente.id);
    if (mounted) {
      setState(() {
        if (h != null) {
          _motivo.text = h.motivoConsulta;
          _antecedentes.text = h.antecedentes;
          _observaciones.text = h.observaciones;
          _diagCodigo = h.diagnosticoCodigo;
          _diagNombre = h.diagnosticoNombre;
        }
        _evoluciones = evo;
        _cargando = false;
      });
    }
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    final error = await HistoriaService.instance.guardar(HistoriaClinica(
      pacienteId: widget.paciente.id,
      motivoConsulta: _motivo.text.trim(),
      antecedentes: _antecedentes.text.trim(),
      diagnosticoCodigo: _diagCodigo,
      diagnosticoNombre: _diagNombre,
      observaciones: _observaciones.text.trim(),
    ));
    if (!mounted) return;
    setState(() => _guardando = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ?? 'Historia clínica guardada ✓'),
      backgroundColor:
          error == null ? const Color(0xFF059669) : const Color(0xFFDC2626),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlatTheme.softBg,
      appBar: AppBar(
        backgroundColor: PlatTheme.darkNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Historia clínica · ${widget.paciente.nombre}',
            style: const TextStyle(color: Colors.white, fontSize: 15)),
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: PlatTheme.purple))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _label('Motivo de consulta'),
                _campo(_motivo, 'Describe el motivo principal...', 3),
                const SizedBox(height: 18),
                _label('Antecedentes'),
                _campo(_antecedentes,
                    'Antecedentes personales, familiares, médicos...', 4),
                const SizedBox(height: 18),
                _label('Diagnóstico (DSM-5 / CIE-10)'),
                _selectorDiagnostico(),
                const SizedBox(height: 18),
                _label('Observaciones del psicólogo'),
                _campo(_observaciones, 'Observaciones clínicas...', 4),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _guardando ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PlatTheme.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
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
                        : const Text('Guardar historia clínica',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 28),
                Container(height: 1, color: const Color(0xFFEFECFF)),
                const SizedBox(height: 20),
                _evolucionSeccion(),
              ],
            ),
    );
  }

  // ── Diagnóstico ────────────────────────────────────────────────────────────
  Widget _selectorDiagnostico() {
    return GestureDetector(
      onTap: _abrirBuscadorDiagnostico,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E4FF)),
        ),
        child: Row(
          children: [
            const Icon(Icons.medical_information_rounded,
                color: PlatTheme.purple, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: _diagCodigo.isEmpty
                  ? const Text('Buscar y seleccionar diagnóstico...',
                      style: TextStyle(color: PlatTheme.textGray, fontSize: 14))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_diagCodigo,
                            style: const TextStyle(
                                color: PlatTheme.purple,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                        Text(_diagNombre,
                            style: const TextStyle(
                                color: PlatTheme.textDark, fontSize: 13.5)),
                      ],
                    ),
            ),
            const Icon(Icons.search_rounded, color: PlatTheme.textGray, size: 20),
          ],
        ),
      ),
    );
  }

  void _abrirBuscadorDiagnostico() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BuscadorDiagnostico(
        onSelect: (d) {
          setState(() {
            _diagCodigo = d.codigo;
            _diagNombre = d.nombre;
          });
        },
      ),
    );
  }

  // ── Evolución ──────────────────────────────────────────────────────────────
  Widget _evolucionSeccion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.timeline_rounded,
                color: PlatTheme.purple, size: 20),
            const SizedBox(width: 8),
            const Text('Evolución por sesión',
                style: TextStyle(
                    color: PlatTheme.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const Spacer(),
            GestureDetector(
              onTap: _agregarEvolucion,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                    color: PlatTheme.purple,
                    borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text('Agregar',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_evoluciones.isEmpty)
          const Text('Aún no hay registros de evolución.',
              style: TextStyle(color: PlatTheme.textGray, fontSize: 13))
        else
          ..._evoluciones.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEFECFF))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_fecha(e.fecha),
                            style: const TextStyle(
                                color: PlatTheme.purple,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                        const Spacer(),
                        if (e.psicologoNombre.isNotEmpty)
                          Text(e.psicologoNombre,
                              style: const TextStyle(
                                  color: PlatTheme.textGray, fontSize: 11.5)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(e.contenido,
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

  Future<void> _agregarEvolucion() async {
    final ctrl = TextEditingController();
    final texto = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Nueva evolución',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Describe la evolución de esta sesión...',
            filled: true,
            fillColor: PlatTheme.softBg,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE8E4FF))),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar',
                  style: TextStyle(color: PlatTheme.textGray))),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            style: ElevatedButton.styleFrom(
                backgroundColor: PlatTheme.purple, foregroundColor: Colors.white),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (texto == null || texto.isEmpty) return;
    await HistoriaService.instance.agregarEvolucion(widget.paciente.id, texto);
    _cargar();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t,
            style: const TextStyle(
                color: PlatTheme.textDark,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      );

  Widget _campo(TextEditingController c, String hint, int lineas) {
    return TextField(
      controller: c,
      maxLines: lineas,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: PlatTheme.textGray, fontSize: 13.5),
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
    );
  }

  String _fecha(DateTime d) {
    const m = ['', 'ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago',
      'sep', 'oct', 'nov', 'dic'];
    final h = d.hour.toString().padLeft(2, '0');
    final mn = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${m[d.month]} ${d.year} · $h:$mn';
  }
}

// ── Buscador de diagnóstico ─────────────────────────────────────────────────

class _BuscadorDiagnostico extends StatefulWidget {
  final void Function(Diagnostico) onSelect;
  const _BuscadorDiagnostico({required this.onSelect});

  @override
  State<_BuscadorDiagnostico> createState() => _BuscadorDiagnosticoState();
}

class _BuscadorDiagnosticoState extends State<_BuscadorDiagnostico> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final resultados = buscarDiagnosticos(_q);
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFE8E4FF),
                  borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _q = v),
              decoration: InputDecoration(
                hintText: 'Buscar (ej. ansiedad, F41, depresión)...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: PlatTheme.softBg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE8E4FF))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE8E4FF))),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: resultados.length,
              itemBuilder: (ctx, i) {
                final d = resultados[i];
                return ListTile(
                  leading: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF0EEFF),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(d.codigo,
                        style: const TextStyle(
                            color: PlatTheme.purple,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                  title: Text(d.nombre,
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w500)),
                  subtitle: Text(d.categoria,
                      style: const TextStyle(
                          color: PlatTheme.textGray, fontSize: 11.5)),
                  onTap: () {
                    widget.onSelect(d);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
