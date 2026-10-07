import 'package:flutter/material.dart';
import 'package:s_inventory/core/estilostexto.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/pages/recoverycodes.dart';
import 'package:s_inventory/pages/splashcreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _userService = UserService();

  bool _isLoading = false;
  bool _mostrarContrasena = false;

  Widget _campo(
    String label,
    TextEditingController controller, {
    bool contrasena = false,
  }) {
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
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: TextField(
        controller: controller,
        obscureText: contrasena && !_mostrarContrasena,
        keyboardType: contrasena
            ? TextInputType.text
            : TextInputType.emailAddress,
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
          suffixIcon: contrasena
              ? IconButton(
                  icon: Icon(
                    _mostrarContrasena
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      _mostrarContrasena = !_mostrarContrasena;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final email = _emailController.text.trim();
    final contrasena = _contrasenaController.text.trim();

    if (email.isEmpty || contrasena.isEmpty) {
      _mostrarMensaje(
        'Ingresa tu correo y contraseña',
        esError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final respuesta = await _userService.loginUsuario(
        email,
        contrasena,
      );

      final prefs = await SharedPreferences.getInstance();

      final token = respuesta['token'] ?? '';
      await prefs.setString('jwt_token', token);

      final nombreUsuario = respuesta['usuario']?['nombre'] ?? '';
      await prefs.setString('user_name', nombreUsuario);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Splashscreen(
            irAlHome: true,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        _mostrarMensaje(
          e.toString(),
          esError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _mostrarMensaje(
    String mensaje, {
    bool esError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError
            ? Colors.red.shade700
            : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(30),
          padding: const EdgeInsets.all(20),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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

              const SizedBox(height: 30),

              _campo(
                'Correo Electrónico',
                _emailController,
              ),

              const SizedBox(height: 30),

              _campo(
                'Contraseña',
                _contrasenaController,
                contrasena: true,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const Recoverypassword(),
                      ),
                    );
                  },
                  child: const Text(
                    '¿Has olvidado tu contraseña?',
                    style: Estilotextos.textoOlvidasteContrasena,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.fondo,
                  disabledBackgroundColor: Colors.white,
                  disabledForegroundColor: AppColors.fondo,
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed:
                    _isLoading ? null : _iniciarSesion,
                child: _isLoading
                    ? const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Iniciar sesion',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

