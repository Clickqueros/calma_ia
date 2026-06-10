import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import '../../core/roles/user_role.dart';
import '../../core/access/clinical_data_guard.dart';
import '../../core/supabase/supabase_config.dart';
import '../services/perfil_admin_service.dart';
import '../widgets/status_badge.dart';

/// Pacientes reales (vista administrativa, datos NO clínicos).
class PatientsAdminScreen extends StatefulWidget {
  const PatientsAdminScreen({super.key});

  @override
  State<PatientsAdminScreen> createState() => _PatientsAdminScreenState();
}

class _PatientsAdminScreenState extends State<PatientsAdminScreen> {
  List<PerfilAdmin> _pacientes = [];
  Map<String, String> _psicologos = {}; // id -> nombre
  bool _cargando = true;

  bool get _small => MediaQuery.of(context).size.width < 900;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final todos = await PerfilAdminService.instance.listarTodos();
    if (mounted) {
      setState(() {
        _pacientes = todos.where((p) => p.rol == 'patient').toList();
        _psicologos = {
          for (final p in todos.where((p) => p.rol == 'psychologist'))
            p.id: p.nombre
        };
        _cargando = false;
      });
    }
  }

  String _nombrePsico(String? id) {
    if (id == null) return 'Sin asignar';
    return _psicologos[id] ?? 'Psicólogo';
  }

  @override
  Widget build(BuildContext context) {
    if (!SupabaseConfig.isConfigured) {
      return const EmptyState(
          icono: Icons.cloud_off_rounded,
          titulo: 'Backend no configurado',
          subtitulo: 'Conecta Supabase para ver pacientes reales.');
    }
    if (_cargando) {
      return const Center(
          child: CircularProgressIndicator(color: PlatTheme.purple));
    }
    final pad = _small ? 18.0 : 32.0;
    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView(
        padding: EdgeInsets.all(pad),
        children: [
          _bannerPrivacidad(),
          const SizedBox(height: 18),
          Row(
            children: [
              Text('${_pacientes.length} pacientes registrados',
                  style: const TextStyle(
                      color: PlatTheme.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    color: PlatTheme.textGray, size: 20),
                onPressed: _cargar,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_pacientes.isEmpty)
            const EmptyState(
                icono: Icons.people_outline_rounded,
                titulo: 'Aún no hay pacientes',
                subtitulo: 'Aparecerán aquí cuando se registren en la app.')
          else
            ..._pacientes.map(_pacienteCard),
        ],
      ),
    );
  }

  Widget _bannerPrivacidad() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EEFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8CFFF)),
      ),
      child: const Row(
        children: [
          Icon(Icons.privacy_tip_rounded, color: PlatTheme.purple, size: 19),
          SizedBox(width: 11),
          Expanded(
            child: Text(
                'Vista administrativa. Solo datos de cuenta. La información clínica '
                '(historia, diario) está protegida y requiere autorización.',
                style: TextStyle(
                    color: Color(0xFF4C1D95), fontSize: 12.5, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _pacienteCard(PerfilAdmin p) {
    final asignado = p.psicologoId != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFECFF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, gradient: PlatTheme.purpleGradient),
                child: Center(
                  child: Text(
                      p.nombre.isNotEmpty ? p.nombre[0].toUpperCase() : '?',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(p.nombre,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: PlatTheme.textDark,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(p.activo
                            ? BadgeStatus.activo
                            : BadgeStatus.inactivo),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(p.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: PlatTheme.textGray, fontSize: 12.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFF2F0FF)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(asignado ? Icons.link_rounded : Icons.link_off_rounded,
                  size: 14,
                  color: asignado
                      ? const Color(0xFF059669)
                      : PlatTheme.textGray),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Psicólogo: ${_nombrePsico(p.psicologoId)}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: asignado
                            ? const Color(0xFF059669)
                            : PlatTheme.textGray,
                        fontSize: 12.5)),
              ),
              // Acción que demuestra la protección de datos clínicos
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ClinicalDataGuard(
                    modulo: SensitiveModule.clinicalHistory,
                    pacienteRef: p.email,
                    pacienteId: p.id,
                    builder: (_) => Scaffold(
                      appBar: AppBar(
                          backgroundColor: PlatTheme.darkNavy,
                          title: const Text('Historia clínica',
                              style: TextStyle(color: Colors.white))),
                      body: const Center(child: Text('Acceso autorizado')),
                    ),
                  ),
                )),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFCD9A8)),
                    color: const Color(0xFFFFF7ED),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_rounded,
                          size: 13, color: Color(0xFFD97706)),
                      SizedBox(width: 5),
                      Text('Historia clínica',
                          style: TextStyle(
                              color: Color(0xFFD97706),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
