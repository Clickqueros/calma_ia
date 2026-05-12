import 'package:flutter/material.dart';
import '../models/cita_model.dart';

class CalendarioWidget extends StatefulWidget {
  final DateTime? fechaSeleccionada;
  final ValueChanged<DateTime> onSeleccionar;

  const CalendarioWidget({
    super.key,
    required this.fechaSeleccionada,
    required this.onSeleccionar,
  });

  @override
  State<CalendarioWidget> createState() => _CalendarioWidgetState();
}

class _CalendarioWidgetState extends State<CalendarioWidget> {
  late DateTime _mesActual;

  static const _purple = Color(0xFF6B4EFF);
  static const _cabeceras = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    _mesActual = DateTime(hoy.year, hoy.month);
  }

  void _prevMes() {
    final hoy = DateTime.now();
    final mesMin = DateTime(hoy.year, hoy.month);
    if (_mesActual.isAfter(mesMin)) {
      setState(() => _mesActual = DateTime(_mesActual.year, _mesActual.month - 1));
    }
  }

  void _nextMes() {
    setState(() => _mesActual = DateTime(_mesActual.year, _mesActual.month + 1));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEEBFF)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildDayLabels(),
          _buildGrid(),
          _buildLeyenda(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final hoy = DateTime.now();
    final puedeRetroceder =
        _mesActual.isAfter(DateTime(hoy.year, hoy.month));

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: puedeRetroceder ? _prevMes : null,
            icon: Icon(Icons.chevron_left_rounded,
                color: puedeRetroceder
                    ? _purple
                    : const Color(0xFFD1D5DB)),
            splashRadius: 20,
          ),
          Expanded(
            child: Text(
              '${nombreMes(_mesActual.month).toUpperCase()} ${_mesActual.year}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1A1A2E),
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          IconButton(
            onPressed: _nextMes,
            icon: const Icon(Icons.chevron_right_rounded, color: _purple),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildDayLabels() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _cabeceras
            .map((d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        color: ['Sáb', 'Dom'].contains(d)
                            ? const Color(0xFFD1D5DB)
                            : const Color(0xFF9CA3AF),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildGrid() {
    final primer = DateTime(_mesActual.year, _mesActual.month, 1);
    // weekday: 1=Mon...7=Sun → offset = weekday - 1
    final offset = primer.weekday - 1;
    final diasEnMes = DateTime(_mesActual.year, _mesActual.month + 1, 0).day;

    final celdas = offset + diasEnMes;
    final filas = (celdas / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: List.generate(filas, (fila) {
          return Row(
            children: List.generate(7, (col) {
              final idx = fila * 7 + col;
              if (idx < offset || idx >= offset + diasEnMes) {
                return const Expanded(child: SizedBox(height: 46));
              }
              final dia = idx - offset + 1;
              final fecha = DateTime(_mesActual.year, _mesActual.month, dia);
              return Expanded(child: _diaCell(fecha));
            }),
          );
        }),
      ),
    );
  }

  Widget _diaCell(DateTime fecha) {
    final disponible = esDiaDisponible(fecha);
    final seleccionado = widget.fechaSeleccionada != null &&
        widget.fechaSeleccionada!.year == fecha.year &&
        widget.fechaSeleccionada!.month == fecha.month &&
        widget.fechaSeleccionada!.day == fecha.day;

    final hoy = DateTime.now();
    final esHoy = fecha.year == hoy.year &&
        fecha.month == hoy.month &&
        fecha.day == hoy.day;

    final esFinDeSemana =
        fecha.weekday == DateTime.saturday || fecha.weekday == DateTime.sunday;

    return GestureDetector(
      onTap: disponible ? () => widget.onSeleccionar(fecha) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.all(3),
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: seleccionado
              ? const LinearGradient(
                  colors: [_purple, Color(0xFF9B8FFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: seleccionado
              ? null
              : disponible
                  ? const Color(0xFFF5F3FF)
                  : null,
          border: esHoy && !seleccionado
              ? Border.all(color: _purple, width: 1.5)
              : seleccionado
                  ? null
                  : Border.all(color: Colors.transparent),
          boxShadow: seleccionado
              ? [
                  BoxShadow(
                      color: _purple.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3))
                ]
              : [],
        ),
        child: Center(
          child: Text(
            '${fecha.day}',
            style: TextStyle(
              color: seleccionado
                  ? Colors.white
                  : disponible
                      ? const Color(0xFF1A1A2E)
                      : esFinDeSemana
                          ? const Color(0xFFD1D5DB)
                          : const Color(0xFFD1D5DB),
              fontSize: 13,
              fontWeight: seleccionado || disponible
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeyenda() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _leyendaItem(const Color(0xFFF5F3FF), 'Disponible'),
          const SizedBox(width: 20),
          _leyendaItem(_purple, 'Seleccionado'),
          const SizedBox(width: 20),
          _leyendaItem(const Color(0xFFF3F4F6), 'No disponible'),
        ],
      ),
    );
  }

  Widget _leyendaItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: const Color(0xFFE5E7EB))),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                color: Color(0xFF9CA3AF), fontSize: 10)),
      ],
    );
  }
}
