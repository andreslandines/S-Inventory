import 'package:flutter/material.dart';
import 'package:s_inventory/pantallas/iniciologo.dart';
import 'package:s_inventory/pantallas/login.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
     return const MaterialApp(
      debugShowCheckedModeBanner:false ,
      home: Scaffold(
        body:SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iniciologo(),
              login(),
              

            ],
          ),
        ),
      ),
    );
  }
}
