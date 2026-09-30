import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/pages/recoverycodes.dart';
import '../services/user_service.dart';
import '../components/login.dart';

class password extends StatefulWidget {
  final String email;
  final String codigo;

  const password({super.key, required this.email, required this.codigo});

  @override
  State<password> createState() => _passwordState();
}

class _passwordState extends State<password> {
  final _nueva = TextEditingController();
  final _confirmar = TextEditingController();
  final _userService = UserService();

  bool _verNueva = false;
  bool _verConfirmar = false;

  String get _pass => _nueva.text;

  Map<String, bool> get _requisitos => {
        'Mínimo 8 caracteres': _pass.length >= 8,
        'Una letra mayúscula': RegExp(r'[A-Z]').hasMatch(_pass),
        'Una letra minúscula': RegExp(r'[a-z]').hasMatch(_pass),
        'Un número': RegExp(r'[0-9]').hasMatch(_pass),
        'Un carácter especial':
            RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(_pass),
      };

  bool get _contrasenaValida => _requisitos.values.every((c) => c);

  bool get _coinciden => _pass == _confirmar.text && _confirmar.text.isNotEmpty;

  Future<void> _cambiarContrasena() async {
    if (!_contrasenaValida) {
      return _mostrarMensaje('La contraseña no cumple los requisitos');
    }
    if (!_coinciden) {
      return _mostrarMensaje('Las contraseñas no coinciden');
    }

    try {
      await _userService.verificarCodigo(widget.email, widget.codigo, _pass);
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      _mostrarMensaje(e.toString());
    }
  }

  void _mostrarMensaje(String mensaje, [bool esError = true]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _requisito(String texto, bool cumplido) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            cumplido ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 17,
            color: cumplido ? Colors.white : Colors.white38,
          ),
          const SizedBox(width: 8),
          Text(
            texto,
            style: TextStyle(
              color: cumplido ? Colors.white : Colors.white60,
              fontSize: 13,
              fontWeight: cumplido ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _campo(
    String label,
    TextEditingController controller,
    bool ver,
    VoidCallback cambiarVisibilidad,
  ) {
    OutlineInputBorder borde(Color color, double ancho) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color, width: ancho),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        obscureText: !ver,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          floatingLabelStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.06),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
          enabledBorder: borde(Colors.white24, 1),
          focusedBorder: borde(Colors.white, 1.5),
          suffixIcon: IconButton(
            icon: Icon(
              ver ? Icons.visibility : Icons.visibility_off,
              color: Colors.white70,
            ),
            onPressed: cambiarVisibilidad,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nueva.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const margenRequisitos = EdgeInsets.fromLTRB(25, 10, 25, 0);

    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.9,
          heightFactor: 0.9,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.fondo,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: Column(
                  children: [

                    Align(alignment: Alignment.topLeft,
                      child: Padding(padding: const EdgeInsets.only(left: 2, top: 2),
                        child: IconButton(onPressed: () {Navigator.push(context,
                      MaterialPageRoute(
                    builder: (context) => const Recoverypassword(),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 10),
                    const Text(
                      "S-Inventory",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Cambiar contraseña",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 25),
                    _campo(
                      'Nueva contraseña',
                      _nueva,
                      _verNueva,
                      () => setState(() => _verNueva = !_verNueva),
                    ),
                    if (_pass.isNotEmpty)
                      Padding(
                        padding: margenRequisitos,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _requisitos.entries
                              .map((e) => _requisito(e.key, e.value))
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: 20),
                    _campo(
                      'Confirmar contraseña',
                      _confirmar,
                      _verConfirmar,
                      () => setState(() => _verConfirmar = !_verConfirmar),
                    ),
                    if (_confirmar.text.isNotEmpty)
                      Padding(
                        padding: margenRequisitos,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _requisito(
                            'Las contraseñas coinciden',
                            _coinciden,
                          ),
                        ),
                      ),
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _contrasenaValida && _coinciden
                              ? _cambiarContrasena
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.fondo,
                            disabledBackgroundColor: Colors.white,
                            disabledForegroundColor: AppColors.fondo,
                            elevation: 4,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Cambiar contraseña",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}