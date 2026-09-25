import 'package:flutter/material.dart';
import 'package:s_inventory/core/estilostexto.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/pages/recoverycodes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';
import '../pages/home.dart';

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
      _mostrarMensaje('Ingresa tu correo y contraseña', esError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final respuesta = await _userService.loginUsuario(email, contrasena);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', respuesta['token']);
      await prefs.setString('user_name', respuesta['usuario']['nombre']);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      if (mounted) {
        _mostrarMensaje(e.toString(), esError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700,
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
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.secondary, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: Image(
                  image: AssetImage("assets/images/logo.png"),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Text("S-Inventory", style: Estilotextos.Titulos),
              Text(
                "Gestion inteligente de inventario",
                style: Estilotextos.textoSecundario,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  labelStyle: Estilotextos.label,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _contrasenaController,
                obscureText: !_mostrarContrasena,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: Estilotextos.label,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _mostrarContrasena
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        _mostrarContrasena = !_mostrarContrasena;
                      });
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Recoverypassword(),
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
                  backgroundColor: AppColors.fondoComponenteSeleccionado,
                ),
                onPressed: _isLoading ? null : _iniciarSesion,
                child: _isLoading
                    ? const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Iniciar sesion',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
