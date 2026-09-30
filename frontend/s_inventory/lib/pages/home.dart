//lib/pages/home.dart
import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/pages/splashcreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/login.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _nombre = '';

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  // Lee el nombre guardado en el login, para mostrarlo en pantalla
Future<void> _cargarUsuario() async {
  final prefs = await SharedPreferences.getInstance();

  setState(() {
    _nombre = prefs.getString('user_name') ?? 'Usuario';
  });
}

// Cierra sesión: borra el token guardado y regresa al Login
Future<void> _cerrarSesion() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  if (!mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const Splashscreen()),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.fondo,
        title: Text('Bienvenido, $_nombre',
        style:  TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white
          )),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Bienvenido a S-Inventory',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}