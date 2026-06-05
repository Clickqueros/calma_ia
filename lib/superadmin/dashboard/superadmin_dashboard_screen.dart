import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import '../data/superadmin_demo_data.dart';

class SuperAdminDashboardScreen extends StatelessWidget {
  const SuperAdminDashboardScreen({super.key});

  bool _small(BuildContext c) => MediaQuery.of(c).size.width < 900;

  @override
  Widget build(BuildContext context) {
    final small = _small(context);
    final pad = small ? 18.0 : 32.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumen general de la plataforma',
              style: TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text(
              'Vista administrativa. Las métricas de bienestar son agregadas y anónimas.',
              style: TextStyle(color: PlatTheme.textGray, fontSize: 14.5)),
          const SizedBox(height: 24),
          _metricas(small),
          const SizedBox(height: 20),
          small
              ? Column(children: [
                  _usoCard(),
                  const SizedBox(height: 20),
                  _alertasCard(),
                ])
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _usoCard()),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: _alertasCard()),
                  ],
                ),
          const SizedBox(height: 20),
          small
              ? Column(children: [
                  _bienestarCard(),
                  const SizedBox(height: 20),
                  _recursosCard(),
                ])
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _bienestarCard()),
                    const SizedBox(width: 20),
                    Expanded(flex: 3, child: _recursosCard()),
                  ],
                ),
        ],
      ),
    );
  }

  // ── Métricas ─────────────────────────────────────────────────────────────

  Widget _metricas(bool small) {
    final cols = small ? 2 : 3;
    return GridView.count(
      crossAxisCount: cols,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: small ? 1.55 : 2.5,
      children: metricasGlobales.map(_metricaCard).toList(),
    );
  }

  Widget _metricaCard(MetricaGlobal m) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFECFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: m.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(m.icono, color: m.color, size: 20),
              ),
              const Spacer(),
              Text(m.valor,
                  style: const TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(m.label,
              style: const TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 1),
          Text(m.detalle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: PlatTheme.textGray, fontSize: 11.5)),
        ],
      ),
    );
  }

  // ── Uso semanal ──────────────────────────────────────────────────────────

  Widget _usoCard() {
    return _card(
      titulo: 'Uso de la plataforma',
      subtitulo: 'Actividad agregada esta semana',
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: usoSemanal.map((d) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 26,
                  height: 110 * d.$2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(
                      colors: [PlatTheme.purple, PlatTheme.softPurple],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(d.$1,
                    style: const TextStyle(
                        color: PlatTheme.textGray, fontSize: 11)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Alertas ──────────────────────────────────────────────────────────────

  Widget _alertasCard() {
    return _card(
      titulo: 'Alertas técnicas y administrativas',
      child: Column(
        children: alertasAdmin
            .map((a) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PlatTheme.softBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: a.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(a.icono, color: a.color, size: 17),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.texto,
                                style: const TextStyle(
                                    color: PlatTheme.textDark,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600)),
                            Text(a.detalle,
                                style: const TextStyle(
                                    color: PlatTheme.textGray, fontSize: 11.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  // ── Bienestar anónimo ────────────────────────────────────────────────────

  Widget _bienestarCard() {
    return _card(
      titulo: 'Bienestar (anónimo)',
      subtitulo: 'Distribución agregada, sin datos identificables',
      child: Column(
        children: bienestarAgregado.map((b) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(b.$1,
                          style: const TextStyle(
                              color: PlatTheme.textDark, fontSize: 12.5)),
                    ),
                    Text('${b.$2}%',
                        style: TextStyle(
                            color: b.$3,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: b.$2 / 100,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFEFECFF),
                    valueColor: AlwaysStoppedAnimation(b.$3),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Recursos más usados ──────────────────────────────────────────────────

  Widget _recursosCard() {
    return _card(
      titulo: 'Recursos más usados',
      subtitulo: 'Uso agregado en toda la plataforma',
      child: Column(
        children: recursosMasUsados.asMap().entries.map((e) {
          final r = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EEFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('${e.key + 1}',
                        style: const TextStyle(
                            color: PlatTheme.purple,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(r.$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: PlatTheme.textDark, fontSize: 13)),
                ),
                Text('${r.$2}',
                    style: const TextStyle(
                        color: PlatTheme.textGray,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Helper ───────────────────────────────────────────────────────────────

  Widget _card({required String titulo, String? subtitulo, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEFECFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          if (subtitulo != null) ...[
            const SizedBox(height: 3),
            Text(subtitulo,
                style: const TextStyle(
                    color: PlatTheme.textGray, fontSize: 12.5)),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
