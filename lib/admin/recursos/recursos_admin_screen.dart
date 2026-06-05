import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import '../data/demo_data.dart';

class RecursosAdminScreen extends StatelessWidget {
  const RecursosAdminScreen({super.key});

  bool _small(BuildContext c) => MediaQuery.of(c).size.width < 900;

  @override
  Widget build(BuildContext context) {
    final small = _small(context);
    final pad = small ? 20.0 : 36.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recursos terapéuticos',
              style: TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text(
              'Comparte PDFs, audios, videos o enlaces con tus pacientes.',
              style: TextStyle(color: PlatTheme.textGray, fontSize: 15)),
          const SizedBox(height: 22),
          _bannerCompartir(),
          const SizedBox(height: 24),
          const Text('Biblioteca por categoría',
              style: TextStyle(
                  color: PlatTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _grid(context, small),
        ],
      ),
    );
  }

  Widget _bannerCompartir() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PlatTheme.darkNavy, Color(0xFF2D1B69)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enviar recurso a un paciente',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Asócialo a una tarea, sesión o tratamiento.',
                    style: TextStyle(color: PlatTheme.softBlue, fontSize: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _grid(BuildContext context, bool small) {
    final cols = small ? 2 : 4;
    return GridView.count(
      crossAxisCount: cols,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.0,
      children: categoriasRecursos.map((c) => _catCard(context, c)).toList(),
    );
  }

  Widget _catCard(BuildContext context, (IconData, String, int, Color) c) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ver recursos de ${c.$2} (demo)'),
          backgroundColor: PlatTheme.darkNavy,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEFECFF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c.$4.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(c.$1, color: c.$4, size: 23),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.$2,
                    style: const TextStyle(
                        color: PlatTheme.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('${c.$3} recursos',
                    style: const TextStyle(
                        color: PlatTheme.textGray, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
