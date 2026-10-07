//lib/pages/home.dart
import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/core/estilostexto.dart';
import 'package:s_inventory/pages/ajustes.dart';
import 'package:s_inventory/pages/boxia.dart';
import 'package:s_inventory/pages/home1.dart';
import 'package:s_inventory/pages/inventario.dart';
import 'package:s_inventory/pages/reportes.dart';
import 'package:s_inventory/pages/splashcreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/login.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin{
  String _nombre = '';
  String _correo = '';
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _cargarUsuario();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  

  // Lee el nombre guardado en el login, para mostrarlo en pantalla
Future<void> _cargarUsuario() async {
  final prefs = await SharedPreferences.getInstance();

  setState(() {
    _nombre = prefs.getString('user_name') ?? 'Usuario';
    _correo = prefs.getString('user_email') ?? 'Correo no disponible';
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
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
      backgroundColor: AppColors.fondo,
      toolbarHeight: 60,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
              ' Bienvenido $_nombre',
              style: Estilotextos.Titulos.copyWith(fontSize: 22),
              ),
              Text(
              ' $_correo',
              style: Estilotextos.textoSecundario,
              ),
            ],
          ),
    ),
      body: TabBarView(
  controller: _tabController,
  children: [
        Home1(),
        Inventario(),
        Boxia(),
        Reportes(),
        Ajustes(),
        ],
      ),
      bottomNavigationBar: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicator: BoxDecoration(),
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'Inicio'),
            Tab(icon: Icon(Icons.inventory_sharp), text: 'Inventario'),
            Tab(icon: Icon(Icons.chat_outlined), text: 'BoxIA'),
            Tab(icon: Icon(Icons.report_gmailerrorred_outlined), text: 'Reportes'),
            Tab(icon: Icon(Icons.person), text: 'Ajustes'),
            ],
          ),
      );
    }
  }