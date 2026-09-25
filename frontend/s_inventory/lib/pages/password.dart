import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import '../services/user_service.dart';
import '../components/login.dart';

class password extends StatefulWidget {
  final String email;
  final String codigo;

  const password({
    super.key,
    required this.email,
    required this.codigo,
  });

  @override
  State<password> createState() => _passwordState();
}

class _passwordState extends State<password> {
  final _nuevaContrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();
  final _userService = UserService();

  bool _mostrarContrasena = false;
  bool _mostrarConfirmacion = false;

  bool get _contrasenaValida {
    final password = _nuevaContrasenaController.text;

    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(password);
  }

  bool get _contrasenasCoinciden {
    return _nuevaContrasenaController.text ==
            _confirmarContrasenaController.text &&
        _confirmarContrasenaController.text.isNotEmpty;
  }

  Future<void> _cambiarContrasena() async {
    if (!_contrasenaValida) {
      _mostrarMensaje('La contraseña no cumple los requisitos', true);
      return;
    }

    if (!_contrasenasCoinciden) {
      _mostrarMensaje('Las contraseñas no coinciden', true);
      return;
    }

    try {
      await _userService.verificarCodigo(
        widget.email,
        widget.codigo,
        _nuevaContrasenaController.text,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      _mostrarMensaje(e.toString(), true);
    }
  }

  void _mostrarMensaje(String mensaje, bool esError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _nuevaContrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.9,
          heightFactor: 0.9,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.fondo,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.secondary,
                width: 1.5,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    "S-Inventory",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 60,
                      height: 60,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Cambiar contraseña",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: _nuevaContrasenaController,
                      obscureText: !_mostrarContrasena,
                      onChanged: (value) {
                        setState(() {});
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nueva contraseña',
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: AppColors.primary,
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _mostrarContrasena
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _mostrarContrasena =
                                  !_mostrarContrasena;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  if (_nuevaContrasenaController.text.isNotEmpty)
                    Text(
                      _contrasenaValida
                          ? 'Contraseña válida'
                          : 'Debe tener 8 caracteres, mayúscula, minúscula, número y símbolo',
                      style: TextStyle(
                        color: _contrasenaValida
                            ? Colors.green
                            : Colors.red,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: _confirmarContrasenaController,
                      obscureText: !_mostrarConfirmacion,
                      onChanged: (value) {
                        setState(() {});
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Confirmar contraseña',
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: AppColors.primary,
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _mostrarConfirmacion
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _mostrarConfirmacion =
                                  !_mostrarConfirmacion;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  if (_confirmarContrasenaController.text.isNotEmpty)
                    Text(
                      _contrasenasCoinciden
                          ? 'Las contraseñas coinciden'
                          : 'Las contraseñas no coinciden',
                      style: TextStyle(
                        color: _contrasenasCoinciden
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _contrasenaValida &&
                                _contrasenasCoinciden
                            ? _cambiarContrasena
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.fondoComponenteSeleccionado,
                        ),
                        child: const Text(
                          "Cambiar contraseña",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}