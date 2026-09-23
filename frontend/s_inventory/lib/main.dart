import 'package:flutter/material.dart';
import 'package:s_inventory/pages/iniciologo.dart';
import 'package:s_inventory/pages/home.dart';
import 'package:s_inventory/pantallas/recoverypassword.dart';
import 'package:s_inventory/components/login.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}