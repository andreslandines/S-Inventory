
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:s_inventory/components/inicio/app_bar_home.dart';
import 'package:s_inventory/components/inicio/bottom_navigation.dart';
import 'package:s_inventory/components/inicio/perfil_dialog.dart';
import 'package:s_inventory/components/inicio/login.dart';
import 'package:s_inventory/core/colores.dart';

import 'package:s_inventory/pages/home1.dart';
import 'package:s_inventory/pages/inventario.dart';
import 'package:s_inventory/pages/boxia.dart';
import 'package:s_inventory/pages/reportes.dart';
import 'package:s_inventory/pages/ajustes.dart';
import 'package:s_inventory/pages/notificaciones.dart';
import 'package:s_inventory/pages/registrar_producto.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _nombre = 'Administrador';
  String _correo = '';

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 5,
      vsync: this,
    );

    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _nombre = prefs.getString('user_name') ?? 'Administrador';
      _correo = prefs.getString('user_email') ?? '';
    });
  }

  // Abre el registro desde Inicio.
  // Si guarda correctamente, cambia a Inventario.
  Future<void> _abrirRegistroProducto() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const RegistrarProductoPage(),
      ),
    );

    if (!mounted) return;

    if (resultado == true) {
      _tabController.animateTo(1);
    }
  }

  Future<void> _abrirNotificaciones() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificacionesPage(),
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

void _mostrarPerfil() {
  mostrarPerfil(
    context: context,
    nombre: _nombre,
    correo: _correo,
    cerrarSesion: _cerrarSesion,
  );
}

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBarHome(
        nombre: _nombre,
        onPerfil: _mostrarPerfil,
        onNotificaciones: _abrirNotificaciones,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Home1(
            onAgregarProducto: _abrirRegistroProducto,
            onReportes: () => _tabController.animateTo(3),
          ),
          const Inventario(),
          const Boxia(),
          const Reportes(),
          const Ajustes(),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        controller: _tabController,
      ),
    );
  }
}
