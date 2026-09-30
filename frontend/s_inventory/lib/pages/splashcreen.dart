import 'package:flutter/material.dart';
import 'package:s_inventory/components/login.dart';
import 'dart:async';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/pages/home.dart';

class Splashscreen extends StatefulWidget {
  final bool irAlHome;
  const Splashscreen({super.key, this.irAlHome = false});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      final destino = widget.irAlHome
          ? const HomeScreen()
          : const LoginScreen();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => destino),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: AppColors.primary,
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
          ],
        ),
      ),
    );
  }
}
