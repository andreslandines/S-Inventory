import 'package:flutter/material.dart';
import 'package:s_inventory/components/login.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/core/estilostexto.dart';
import '../services/user_service.dart';
import 'password.dart';

class Recoverypassword extends StatefulWidget {
  const Recoverypassword({super.key});

  @override
  State<Recoverypassword> createState() => _RecoverypasswordState();
}

class _RecoverypasswordState extends State<Recoverypassword> {
  final _emailController = TextEditingController();
  final _codigoController = TextEditingController();
  final _userService = UserService();

  Widget _campo(
    String label,
    TextEditingController controller,
  ) {
    OutlineInputBorder borde(Color color, double ancho) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: color,
          width: ancho,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 16,
          ),
          enabledBorder: borde(Colors.white24, 1),
          focusedBorder: borde(Colors.white, 1.5),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codigoController.dispose();
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

    if (email.isEmpty || codigo.isEmpty) {
      _mostrarMensaje('Completa todos los campos', true);
      return;
    }

    try {
      await _userService.validarCodigo(
        email,
        codigo,
        
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => password(
            email: email,
            codigo: codigo,
          ),
        ),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.9,
          heightFactor: 0.95,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.fondo,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white12,
                width: 1,
              ),
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
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                          top: 8,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const LoginScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    ClipOval(
                      child: Image(
                        image: const AssetImage(
                          "assets/images/logo.png",
                        ),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "S-Inventory",
                      style: Estilotextos.Titulos,
                    ),

                    Text(
                      "Gestion inteligente de inventario",
                      style: Estilotextos.textoSecundario,
                    ),

                    const SizedBox(height: 50),

                    const Text(
                      "Recuperar contraseña",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _campo(
                      'Correo electrónico',
                      _emailController,
                    ),
                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: _enviarCodigo,
                        child: const Text(
                          'Volver a enviar codigo',
                          style: Estilotextos.textoOlvidasteContrasena,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _enviarCodigo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.fondo,
                            disabledBackgroundColor: Colors.white,
                            disabledForegroundColor: AppColors.fondo,
                            elevation: 4,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Enviar codigo",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    _campo(
                      'Codigo',
                      _codigoController,
                    ),
                    const SizedBox(height: 30),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _verificarCodigo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.fondo,
                            disabledBackgroundColor: Colors.white,
                            disabledForegroundColor: AppColors.fondo,
                            elevation: 4,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Verificar codigo",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 200),
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
