import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:s_inventory/components/app_bar_home.dart';
import 'package:s_inventory/components/bottom_navigation.dart';
import 'package:s_inventory/components/perfil_dialog.dart';
import 'package:s_inventory/components/login.dart';

import 'package:s_inventory/core/colores.dart';

import 'package:s_inventory/pages/home1.dart';
import 'package:s_inventory/pages/inventario.dart';
import 'package:s_inventory/pages/boxia.dart';
import 'package:s_inventory/pages/reportes.dart';
import 'package:s_inventory/pages/ajustes.dart';
import 'package:s_inventory/pages/notificaciones.dart';

class Home1Screen extends StatefulWidget {
  const Home1Screen({super.key});

  @override
  State<Home1Screen> createState() => _Home1ScreenState();
}

class _Home1ScreenState extends State<Home1Screen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  String _nombre = '';
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _nombre = prefs.getString('user_name') ?? 'Usuario';
      _correo = prefs.getString('user_email') ?? '';
    });
  }

  Future<void> _cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
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

  void _mostrarNotificaciones() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificacionesPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBarHome(
        nombre: _nombre,
        onPerfil: _mostrarPerfil,
        onNotificaciones: _mostrarNotificaciones,
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Home1Screen(),
          Inventario(),
          Boxia(),
          Reportes(),
          Ajustes(),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        controller: _tabController,
      ),
    );
  }
}