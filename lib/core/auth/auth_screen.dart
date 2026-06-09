import 'package:flutter/material.dart';
import '../../plataforma/theme/plat_theme.dart';
import 'auth_service.dart';

/// Pantalla de inicio de sesión y registro (paciente).
/// Al autenticarse, el diario se sincroniza con Supabase automáticamente.
class AuthScreen extends StatefulWidget {
  /// Si false, oculta el botón "Continuar sin cuenta" (login obligatorio).
  final bool permitirInvitado;

  /// Si se provee, se llama al autenticarse en vez de hacer Navigator.pop.
  /// Útil cuando la pantalla es la puerta de entrada (gate), no un push.
  final VoidCallback? onAutenticado;

  const AuthScreen({
    super.key,
    this.permitirInvitado = true,
    this.onAutenticado,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _esRegistro = false;
  bool _cargando = false;
  String? _error;
  String? _mensaje;
  bool _verPassword = false;
  bool _verConfirmar = false;

  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmar = TextEditingController();

  @override
  void dispose() {
    _nombre.dispose();
    _email.dispose();
    _password.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    // Validaciones del registro
    if (_esRegistro) {
      if (_password.text.length < 6) {
        setState(() => _error = 'La contraseña debe tener al menos 6 caracteres.');
        return;
      }
      if (_password.text != _confirmar.text) {
        setState(() => _error = 'Las contraseñas no coinciden.');
        return;
      }
    }

    setState(() {
      _cargando = true;
      _error = null;
      _mensaje = null;
    });

    String? err;
    if (_esRegistro) {
      err = await AuthService.instance.registrar(
        nombre: _nombre.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        rol: 'patient', // El registro público siempre es paciente.
      );
    } else {
      err = await AuthService.instance.iniciarSesion(
        email: _email.text.trim(),
        password: _password.text,
      );
    }

    if (!mounted) return;
    setState(() => _cargando = false);

    if (err != null) {
      setState(() => _error = err);
      return;
    }

    if (_esRegistro && !AuthService.instance.haySesion) {
      // Supabase pide confirmar email por defecto.
      setState(() => _mensaje =
          'Cuenta creada. Revisa tu correo para confirmar y luego inicia sesión.');
      return;
    }

    // Sesión iniciada.
    if (widget.onAutenticado != null) {
      widget.onAutenticado!();
    } else {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: PlatTheme.darkGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: PlatTheme.purpleGradient),
                          child: const Icon(Icons.self_improvement,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Text('calma',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_esRegistro ? 'Crear cuenta' : 'Iniciar sesión',
                              style: const TextStyle(
                                  color: PlatTheme.textDark,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(
                              _esRegistro
                                  ? 'Tu diario se guardará de forma privada y segura.'
                                  : 'Bienvenido de nuevo a tu espacio de calma.',
                              style: const TextStyle(
                                  color: PlatTheme.textGray, fontSize: 13.5)),
                          const SizedBox(height: 22),
                          if (_esRegistro) ...[
                            _campo(_nombre, 'Nombre', Icons.person_outline_rounded),
                            const SizedBox(height: 14),
                          ],
                          _campo(_email, 'Correo electrónico',
                              Icons.email_outlined,
                              tipo: TextInputType.emailAddress),
                          const SizedBox(height: 14),
                          _campo(_password, 'Contraseña', Icons.lock_outline_rounded,
                              oculto: !_verPassword,
                              conOjo: true,
                              ojoVisible: _verPassword,
                              onToggleOjo: () =>
                                  setState(() => _verPassword = !_verPassword)),
                          if (_esRegistro) ...[
                            const SizedBox(height: 14),
                            _campo(_confirmar, 'Confirmar contraseña',
                                Icons.lock_outline_rounded,
                                oculto: !_verConfirmar,
                                conOjo: true,
                                ojoVisible: _verConfirmar,
                                onToggleOjo: () => setState(
                                    () => _verConfirmar = !_verConfirmar)),
                          ],
                          if (_error != null) ...[
                            const SizedBox(height: 14),
                            _aviso(_error!, const Color(0xFFDC2626),
                                const Color(0xFFFEF2F2)),
                          ],
                          if (_mensaje != null) ...[
                            const SizedBox(height: 14),
                            _aviso(_mensaje!, const Color(0xFF059669),
                                const Color(0xFFE8FAF0)),
                          ],
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _cargando ? null : _enviar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PlatTheme.purple,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: _cargando
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : Text(
                                      _esRegistro
                                          ? 'Crear cuenta'
                                          : 'Iniciar sesión',
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _esRegistro = !_esRegistro;
                                _error = null;
                                _mensaje = null;
                              }),
                              child: RichText(
                                text: TextSpan(
                                  text: _esRegistro
                                      ? '¿Ya tienes cuenta? '
                                      : '¿No tienes cuenta? ',
                                  style: const TextStyle(
                                      color: PlatTheme.textGray, fontSize: 13.5),
                                  children: [
                                    TextSpan(
                                      text: _esRegistro
                                          ? 'Inicia sesión'
                                          : 'Regístrate',
                                      style: const TextStyle(
                                          color: PlatTheme.purple,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.permitirInvitado) ...[
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Continuar sin cuenta',
                            style: TextStyle(
                                color: PlatTheme.softBlue, fontSize: 13)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(TextEditingController c, String hint, IconData icon,
      {bool oculto = false,
      TextInputType? tipo,
      bool conOjo = false,
      bool ojoVisible = false,
      VoidCallback? onToggleOjo}) {
    return TextField(
      controller: c,
      obscureText: oculto,
      keyboardType: tipo,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: PlatTheme.textGray, fontSize: 14),
        prefixIcon: Icon(icon, color: PlatTheme.textGray, size: 20),
        suffixIcon: conOjo
            ? IconButton(
                icon: Icon(
                    ojoVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: PlatTheme.textGray,
                    size: 20),
                onPressed: onToggleOjo,
              )
            : null,
        filled: true,
        fillColor: PlatTheme.softBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E4FF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E4FF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PlatTheme.purple),
        ),
      ),
    );
  }

  Widget _aviso(String texto, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: color, size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: Text(texto,
                style: TextStyle(color: color, fontSize: 12.5, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
