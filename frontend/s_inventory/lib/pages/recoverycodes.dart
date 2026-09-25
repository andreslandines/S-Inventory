import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import '../services/user_service.dart';

class Recoverypassword extends StatefulWidget {
  const Recoverypassword({super.key});

  @override
  State<Recoverypassword> createState() => _RecoverypasswordState();
}

class _RecoverypasswordState extends State<Recoverypassword> {
  final _emailController = TextEditingController();
  final _codigoController = TextEditingController();
  final _nuevaContrasenaController = TextEditingController();
  final _userService = UserService();

  @override
  void dispose() {
    _emailController.dispose();
    _codigoController.dispose();
    _nuevaContrasenaController.dispose();
    super.dispose();
  }

  Future<void> _enviarCodigo() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _mostrarMensaje('Ingresa tu correo', true);
      return;
    }

    try {
      final respuesta = await _userService.enviarCodigo(email);
      _mostrarMensaje(respuesta['message'], false);
    } catch (e) {
      _mostrarMensaje(e.toString(), true);
    }
  }

  Future<void> _verificarCodigo() async {
    final email = _emailController.text.trim();
    final codigo = _codigoController.text.trim();
    final nuevaContrasena = _nuevaContrasenaController.text.trim();

    if (email.isEmpty || codigo.isEmpty || nuevaContrasena.isEmpty) {
      _mostrarMensaje('Completa todos los campos', true);
      return;
    }

    try {
      final respuesta = await _userService.verificarCodigo(
        email,
        codigo,
        nuevaContrasena,
      );
      _mostrarMensaje(respuesta['message'], false);
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
                  Text(
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
                  Text(
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
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Correo electronico',
                        labelStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: AppColors.primary,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _enviarCodigo,
                    child: Text(
                      'Volver a enviar codigo',
                      style: TextStyle(
                        color: AppColors.fondoComponenteSeleccionado,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _enviarCodigo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.fondoComponenteSeleccionado,
                        ),
                        child: Text(
                          "Enviar codigo",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: _codigoController,
                      decoration: InputDecoration(
                        labelText: 'Codigo',
                        labelStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: AppColors.primary,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: _nuevaContrasenaController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Nueva contraseña',
                        labelStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: AppColors.primary,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _verificarCodigo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.fondoComponenteSeleccionado,
                        ),
                        child: Text(
                          "Verificar codigo",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}