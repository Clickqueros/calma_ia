import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import '../../core/auth/perfil_service.dart';
import '../../core/clinica/historia_service.dart';
import '../../core/clinica/diagnosticos.dart';
import '../../core/clinica/rips_catalogos.dart';
import '../../core/clinica/archivo_picker.dart';

class HistoriaClinicaScreen extends StatefulWidget {
  final PacienteVinculado paciente;
  const HistoriaClinicaScreen({super.key, required this.paciente});

  @override
  State<HistoriaClinicaScreen> createState() => _HistoriaClinicaScreenState();
}

class _HistoriaClinicaScreenState extends State<HistoriaClinicaScreen> {
  // Datos del paciente
  final _documento = TextEditingController();
  final _fechaNac = TextEditingController();
  final _ciudad = TextEditingController();
  final _direccion = TextEditingController();
  final _telefono = TextEditingController();
  final _ocupacion = TextEditingController();
  final _entidad = TextEditingController();
  String _sexo = '';
  String _estadoCivil = '';
  String _tipoUsuario = '';
  // Clínico
  final _motivo = TextEditingController();
  final _antecedentes = TextEditingController();
  final _valoracion = TextEditingController();
  final _observaciones = TextEditingController();
  String _diagCodigo = '';
  String _diagNombre = '';

  List<Evolucion> _evoluciones = [];
  HistoriaClinica? _historia;
  bool _cargando = true;
  bool _guardando = false;
  bool _editando = false; // false = vista (tabla), true = formulario
  bool get _tieneDatos =>
      _historia != null &&
      (_historia!.documento.isNotEmpty ||
          _historia!.motivoConsulta.isNotEmpty ||
          _historia!.valoracionInicial.isNotEmpty);

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    for (final c in [
      _documento, _fechaNac, _ciudad, _direccion, _telefono, _ocupacion,
      _entidad, _motivo, _antecedentes, _valoracion, _observaciones
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _cargar() async {
    final h = await HistoriaService.instance.obtener(widget.paciente.id);
    final evo = await HistoriaService.instance.evoluciones(widget.paciente.id);
    if (mounted) {
      setState(() {
        _historia = h;
        // Si no hay datos aún, abrir directo en modo edición.
        _editando = !(_tieneDatos);
        if (h != null) {
          _documento.text = h.documento;
          _fechaNac.text = h.fechaNacimiento;
          _ciudad.text = h.ciudad;
          _direccion.text = h.direccion;
          _telefono.text = h.telefono;
          _ocupacion.text = h.ocupacion;
          _entidad.text = h.entidad;
          _sexo = h.sexo;
          _estadoCivil = h.estadoCivil;
          _tipoUsuario = h.tipoUsuario;
          _motivo.text = h.motivoConsulta;
          _antecedentes.text = h.antecedentes;
          _valoracion.text = h.valoracionInicial;
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
    final h = HistoriaClinica(
      pacienteId: widget.paciente.id,
      documento: _documento.text.trim(),
      fechaNacimiento: _fechaNac.text.trim(),
      sexo: _sexo,
      estadoCivil: _estadoCivil,
      ciudad: _ciudad.text.trim(),
      direccion: _direccion.text.trim(),
      telefono: _telefono.text.trim(),
      ocupacion: _ocupacion.text.trim(),
      entidad: _entidad.text.trim(),
      tipoUsuario: _tipoUsuario,
      motivoConsulta: _motivo.text.trim(),
      antecedentes: _antecedentes.text.trim(),
      valoracionInicial: _valoracion.text.trim(),
      diagnosticoCodigo: _diagCodigo,
      diagnosticoNombre: _diagNombre,
      observaciones: _observaciones.text.trim(),
    );
    final error = await HistoriaService.instance.guardar(h);
    if (!mounted) return;
    setState(() {
      _guardando = false;
      if (error == null) {
        _historia = h;
        _editando = false; // volver a modo vista
      }
    });
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
        title: const Text('Historia clínica',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          if (!_cargando)
            TextButton.icon(
              onPressed: () => setState(() => _editando = !_editando),
              icon: Icon(
                  _editando
                      ? Icons.visibility_rounded
                      : Icons.edit_rounded,
                  color: Colors.white,
                  size: 18),
              label: Text(_editando ? 'Ver' : 'Editar',
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
        ],
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: PlatTheme.purple))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_editando) ..._formulario() else ..._vista(),
                const SizedBox(height: 24),
                _evolucionSeccion(),
              ],
            ),
    );
  }

  // ── Modo VISTA (tabla / documento, solo lectura) ────────────────────────────
  List<Widget> _vista() {
    final h = _historia;
    return [
      _bloqueVista('Datos del paciente', Icons.badge_rounded, [
        ('Nombre', widget.paciente.nombre),
        ('Documento (CC)', h?.documento ?? ''),
        ('Fecha de nacimiento', h?.fechaNacimiento ?? ''),
        ('Sexo', h?.sexo ?? ''),
        ('Estado civil', h?.estadoCivil ?? ''),
        ('Ciudad', h?.ciudad ?? ''),
        ('Teléfono', h?.telefono ?? ''),
        ('Dirección', h?.direccion ?? ''),
        ('Ocupación', h?.ocupacion ?? ''),
        ('Entidad (EPS)', h?.entidad ?? ''),
        ('Tipo de usuario', h?.tipoUsuario ?? ''),
      ]),
      const SizedBox(height: 16),
      _bloqueVistaTexto('Valoración inicial', Icons.assignment_rounded, [
        ('Motivo de consulta', h?.motivoConsulta ?? ''),
        ('Antecedentes', h?.antecedentes ?? ''),
        ('Valoración inicial', h?.valoracionInicial ?? ''),
        if ((h?.diagnosticoCodigo ?? '').isNotEmpty)
          ('Diagnóstico', '${h?.diagnosticoCodigo} · ${h?.diagnosticoNombre}'),
        ('Observaciones', h?.observaciones ?? ''),
      ]),
    ];
  }

  Widget _bloqueVista(
      String titulo, IconData icon, List<(String, String)> filas) {
    final visibles = filas.where((f) => f.$2.trim().isNotEmpty).toList();
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEFECFF))),
      child: Column(
        children: [
          _tituloBloque(titulo, icon),
          if (visibles.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Sin información registrada.',
                    style: TextStyle(color: PlatTheme.textGray, fontSize: 13)),
              ),
            )
          else
            ...visibles.asMap().entries.map((e) {
              final par = e.value;
              final ultimo = e.key == visibles.length - 1;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: ultimo
                      ? null
                      : const Border(
                          bottom: BorderSide(color: Color(0xFFF2F0FF))),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(par.$1,
                          style: const TextStyle(
                              color: PlatTheme.textGray,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(par.$2,
                          style: const TextStyle(
                              color: PlatTheme.textDark, fontSize: 13.5)),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _bloqueVistaTexto(
      String titulo, IconData icon, List<(String, String)> bloques) {
    final visibles = bloques.where((f) => f.$2.trim().isNotEmpty).toList();
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEFECFF))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tituloBloque(titulo, icon),
          if (visibles.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sin información registrada.',
                  style: TextStyle(color: PlatTheme.textGray, fontSize: 13)),
            )
          else
            ...visibles.map((b) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.$1.toUpperCase(),
                          style: const TextStyle(
                              color: PlatTheme.purple,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Text(b.$2,
                          style: const TextStyle(
                              color: PlatTheme.textDark,
                              fontSize: 13.5,
                              height: 1.5)),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _tituloBloque(String titulo, IconData icon) => Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Row(
          children: [
            Icon(icon, color: PlatTheme.purple, size: 20),
            const SizedBox(width: 8),
            Text(titulo,
                style: const TextStyle(
                    color: PlatTheme.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      );

  // ── Modo FORMULARIO (edición) ───────────────────────────────────────────────
  List<Widget> _formulario() {
    return [
      _bloque('Datos del paciente', Icons.badge_rounded, [
        _campo('Nombre',
            TextEditingController(text: widget.paciente.nombre),
            enabled: false),
        _fila([
          _campo('Documento (CC)', _documento),
          _campo('Fecha de nacimiento', _fechaNac, hint: 'dd/mm/aaaa'),
        ]),
        _fila([
          _dropdown('Sexo', _sexo, sexos, (v) => setState(() => _sexo = v)),
          _dropdown('Estado civil', _estadoCivil, estadosCiviles,
              (v) => setState(() => _estadoCivil = v)),
        ]),
        _fila([
          _campo('Ciudad', _ciudad),
          _campo('Teléfono', _telefono),
        ]),
        _campo('Dirección', _direccion),
        _campo('Ocupación', _ocupacion),
        _fila([
          _campo('Entidad (EPS)', _entidad),
          _dropdown('Tipo de usuario', _tipoUsuario, tiposUsuario,
              (v) => setState(() => _tipoUsuario = v)),
        ]),
      ]),
      const SizedBox(height: 16),
      _bloque('Valoración inicial', Icons.assignment_rounded, [
        _campoMultilinea('Motivo de consulta', _motivo, 3),
        _campoMultilinea('Antecedentes', _antecedentes, 3),
        _campoMultilinea('Valoración inicial (narrativa)', _valoracion, 5),
        _labelMini('Diagnóstico (DSM-5 / CIE-10)'),
        _selectorDiagnostico(),
        _campoMultilinea('Observaciones', _observaciones, 3),
      ]),
      const SizedBox(height: 16),
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
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
    ];
  }

  // ── Evolución ──────────────────────────────────────────────────────────────
  Widget _evolucionSeccion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.timeline_rounded, color: PlatTheme.purple, size: 20),
            const SizedBox(width: 8),
            const Text('Evoluciones',
                style: TextStyle(
                    color: PlatTheme.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
            const Spacer(),
            GestureDetector(
              onTap: _nuevaEvolucion,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                    color: PlatTheme.purple,
                    borderRadius: BorderRadius.circular(9)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 17),
                    SizedBox(width: 5),
                    Text('Nueva evolución',
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
          const Text('Aún no hay evoluciones registradas.',
              style: TextStyle(color: PlatTheme.textGray, fontSize: 13))
        else
          ..._evoluciones.map(_evolucionCard),
      ],
    );
  }

  Widget _evolucionCard(Evolucion e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
          if (e.procedimiento.isNotEmpty) ...[
            const SizedBox(height: 8),
            _dato('Procedimiento', e.procedimiento),
          ],
          if (e.diagnosticoCodigo.isNotEmpty)
            _dato('Diagnóstico', '${e.diagnosticoCodigo} · ${e.diagnosticoNombre}'),
          if (e.tipoDiagnostico.isNotEmpty)
            _dato('Tipo dx', e.tipoDiagnostico),
          const SizedBox(height: 8),
          Text(e.evolucion,
              style: const TextStyle(
                  color: PlatTheme.textDark, fontSize: 13.5, height: 1.5)),
          if (e.notaAclaratoria.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Nota: ${e.notaAclaratoria}',
                style: const TextStyle(
                    color: PlatTheme.textGray,
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic)),
          ],
          if (e.adjuntoUrl.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_file_rounded,
                    size: 15, color: PlatTheme.purple),
                const SizedBox(width: 5),
                const Text('Archivo adjunto',
                    style: TextStyle(
                        color: PlatTheme.purple,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _nuevaEvolucion() async {
    final guardada = await Navigator.of(context).push<bool>(MaterialPageRoute(
        builder: (_) => _NuevaEvolucionScreen(paciente: widget.paciente)));
    if (guardada == true) _cargar();
  }

  // ── Diagnóstico ────────────────────────────────────────────────────────────
  Widget _selectorDiagnostico() {
    return GestureDetector(
      onTap: () => abrirBuscadorDiagnostico(context, (d) {
        setState(() {
          _diagCodigo = d.codigo;
          _diagNombre = d.nombre;
        });
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: PlatTheme.softBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE8E4FF))),
        child: Row(
          children: [
            const Icon(Icons.medical_information_rounded,
                color: PlatTheme.purple, size: 19),
            const SizedBox(width: 11),
            Expanded(
              child: _diagCodigo.isEmpty
                  ? const Text('Buscar diagnóstico...',
                      style: TextStyle(color: PlatTheme.textGray, fontSize: 13.5))
                  : Text('$_diagCodigo · $_diagNombre',
                      style: const TextStyle(
                          color: PlatTheme.textDark, fontSize: 13)),
            ),
            const Icon(Icons.search_rounded, color: PlatTheme.textGray, size: 19),
          ],
        ),
      ),
    );
  }

  // ── Helpers de UI ────────────────────────────────────────────────────────────
  Widget _bloque(String titulo, IconData icon, List<Widget> hijos) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEFECFF))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: PlatTheme.purple, size: 20),
              const SizedBox(width: 8),
              Text(titulo,
                  style: const TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ...hijos,
        ],
      ),
    );
  }

  Widget _fila(List<Widget> hijos) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < hijos.length; i++) ...[
          Expanded(child: hijos[i]),
          if (i < hijos.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }

  Widget _labelMini(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t,
            style: const TextStyle(
                color: PlatTheme.textGray,
                fontSize: 12.5,
                fontWeight: FontWeight.w600)),
      );

  Widget _campo(String label, TextEditingController c,
      {bool enabled = true, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labelMini(label),
          TextField(
            controller: c,
            enabled: enabled,
            decoration: _decoracion(hint),
          ),
        ],
      ),
    );
  }

  Widget _campoMultilinea(String label, TextEditingController c, int lineas) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labelMini(label),
          TextField(
            controller: c,
            maxLines: lineas,
            decoration: _decoracion(null),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(String label, String valor, List<String> opciones,
      void Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labelMini(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
                color: PlatTheme.softBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE8E4FF))),
            child: DropdownButton<String>(
              value: valor.isEmpty ? null : valor,
              hint: const Text('Seleccionar',
                  style: TextStyle(color: PlatTheme.textGray, fontSize: 13.5)),
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: opciones
                  .map((o) => DropdownMenuItem(
                      value: o,
                      child: Text(o,
                          style: const TextStyle(fontSize: 13.5))))
                  .toList(),
              onChanged: (v) => onChanged(v ?? ''),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoracion(String? hint) => InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: PlatTheme.softBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE8E4FF))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE8E4FF))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: PlatTheme.purple)),
      );

  Widget _dato(String label, String valor) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: PlatTheme.textGray, fontSize: 12.5),
            children: [
              TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              TextSpan(
                  text: valor,
                  style: const TextStyle(color: PlatTheme.textDark)),
            ],
          ),
        ),
      );

  String _fecha(DateTime d) {
    const m = ['', 'ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago',
      'sep', 'oct', 'nov', 'dic'];
    final h = d.hour.toString().padLeft(2, '0');
    final mn = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${m[d.month]} ${d.year} · $h:$mn';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nueva evolución (formulario estructurado estilo RIPS)
// ─────────────────────────────────────────────────────────────────────────────

class _NuevaEvolucionScreen extends StatefulWidget {
  final PacienteVinculado paciente;
  const _NuevaEvolucionScreen({required this.paciente});

  @override
  State<_NuevaEvolucionScreen> createState() => _NuevaEvolucionScreenState();
}

class _NuevaEvolucionScreenState extends State<_NuevaEvolucionScreen> {
  String _procedimiento = procedimientosCups[1];
  String _tipoDx = tiposDiagnostico[0];
  String _finalidad = finalidadesConsulta.last;
  String _causa = causasExternas[0];
  String _diagCodigo = '';
  String _diagNombre = '';
  final _evolucion = TextEditingController();
  final _nota = TextEditingController();

  String _adjuntoUrl = '';
  String _adjuntoNombre = '';
  bool _subiendo = false;
  bool _guardando = false;

  @override
  void dispose() {
    _evolucion.dispose();
    _nota.dispose();
    super.dispose();
  }

  Future<void> _adjuntar() async {
    final archivo = await elegirArchivo();
    if (archivo == null) return;
    setState(() => _subiendo = true);
    final url = await HistoriaService.instance.subirAdjunto(
      pacienteId: widget.paciente.id,
      nombreArchivo: archivo.nombre,
      bytes: archivo.bytes,
    );
    if (!mounted) return;
    setState(() {
      _subiendo = false;
      if (url != null) {
        _adjuntoUrl = url;
        _adjuntoNombre = archivo.nombre;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No se pudo subir el archivo. ¿Creaste el bucket "adjuntos"?'),
          backgroundColor: Color(0xFFDC2626)));
      }
    });
  }

  Future<void> _guardar() async {
    if (_evolucion.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Escribe la evolución realizada.'),
          backgroundColor: Color(0xFFDC2626)));
      return;
    }
    setState(() => _guardando = true);
    final err = await HistoriaService.instance.agregarEvolucion(
      pacienteId: widget.paciente.id,
      procedimiento: _procedimiento,
      tipoDiagnostico: _tipoDx,
      finalidad: _finalidad,
      causaExterna: _causa,
      diagnosticoCodigo: _diagCodigo,
      diagnosticoNombre: _diagNombre,
      evolucion: _evolucion.text.trim(),
      notaAclaratoria: _nota.text.trim(),
      adjuntoUrl: _adjuntoUrl,
    );
    if (!mounted) return;
    setState(() => _guardando = false);
    if (err == null) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(err), backgroundColor: const Color(0xFFDC2626)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlatTheme.softBg,
      appBar: AppBar(
        backgroundColor: PlatTheme.darkNavy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Nueva evolución',
            style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _lbl('Procedimiento'),
          _drop(_procedimiento, procedimientosCups,
              (v) => setState(() => _procedimiento = v)),
          _lbl('Tipo de diagnóstico'),
          _drop(_tipoDx, tiposDiagnostico, (v) => setState(() => _tipoDx = v)),
          _lbl('Finalidad de la consulta'),
          _drop(_finalidad, finalidadesConsulta,
              (v) => setState(() => _finalidad = v)),
          _lbl('Causa externa'),
          _drop(_causa, causasExternas, (v) => setState(() => _causa = v)),
          _lbl('Diagnóstico CIE-10'),
          GestureDetector(
            onTap: () => abrirBuscadorDiagnostico(context, (d) {
              setState(() {
                _diagCodigo = d.codigo;
                _diagNombre = d.nombre;
              });
            }),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE8E4FF))),
              child: Row(
                children: [
                  const Icon(Icons.medical_information_rounded,
                      color: PlatTheme.purple, size: 19),
                  const SizedBox(width: 11),
                  Expanded(
                    child: _diagCodigo.isEmpty
                        ? const Text('Buscar diagnóstico...',
                            style: TextStyle(
                                color: PlatTheme.textGray, fontSize: 13.5))
                        : Text('$_diagCodigo · $_diagNombre',
                            style: const TextStyle(
                                color: PlatTheme.textDark, fontSize: 13)),
                  ),
                  const Icon(Icons.search_rounded,
                      color: PlatTheme.textGray, size: 19),
                ],
              ),
            ),
          ),
          _lbl('Evolución realizada'),
          TextField(
            controller: _evolucion,
            maxLines: 5,
            decoration: _dec('Describe la evolución de esta sesión...'),
          ),
          const SizedBox(height: 14),
          _lbl('Nota aclaratoria'),
          TextField(
              controller: _nota, maxLines: 2, decoration: _dec('Opcional...')),
          const SizedBox(height: 18),
          _lbl('Archivo adjunto'),
          _adjuntoWidget(),
          const SizedBox(height: 24),
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
                  : const Text('Guardar evolución',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _adjuntoWidget() {
    if (_subiendo) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE8E4FF))),
        child: const Row(
          children: [
            SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.5)),
            SizedBox(width: 12),
            Text('Subiendo archivo...',
                style: TextStyle(color: PlatTheme.textGray, fontSize: 13.5)),
          ],
        ),
      );
    }
    if (_adjuntoUrl.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: const Color(0xFFE8FAF0),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFA7E8C8))),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF059669), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(_adjuntoNombre,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color(0xFF065F46), fontSize: 13)),
            ),
            GestureDetector(
              onTap: () => setState(() {
                _adjuntoUrl = '';
                _adjuntoNombre = '';
              }),
              child: const Icon(Icons.close_rounded,
                  color: Color(0xFFDC2626), size: 18),
            ),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: _adjuntar,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: const Color(0xFFE8E4FF),
                style: BorderStyle.solid)),
        child: const Row(
          children: [
            Icon(Icons.upload_file_rounded, color: PlatTheme.purple, size: 20),
            SizedBox(width: 12),
            Text('Subir PDF o imagen',
                style: TextStyle(color: PlatTheme.textDark, fontSize: 13.5)),
          ],
        ),
      ),
    );
  }

  Widget _lbl(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t,
            style: const TextStyle(
                color: PlatTheme.textGray,
                fontSize: 12.5,
                fontWeight: FontWeight.w600)),
      );

  Widget _drop(String valor, List<String> opciones, void Function(String) on) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE8E4FF))),
      child: DropdownButton<String>(
        value: valor,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: opciones
            .map((o) => DropdownMenuItem(
                value: o,
                child: Text(o,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13))))
            .toList(),
        onChanged: (v) => on(v ?? valor),
      ),
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: PlatTheme.textGray, fontSize: 13.5),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE8E4FF))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE8E4FF))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: PlatTheme.purple)),
      );
}

// ── Buscador de diagnóstico (compartido) ─────────────────────────────────────

void abrirBuscadorDiagnostico(
    BuildContext context, void Function(Diagnostico) onSelect) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BuscadorDiagnostico(onSelect: onSelect),
  );
}

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
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
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
