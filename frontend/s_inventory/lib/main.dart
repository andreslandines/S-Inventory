import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:s_inventory/pantallas/inicio.dart';
import 'package:s_inventory/pantallas/recoverypassword.dart';
=======
import 'package:s_inventory/pantallas/iniciologo.dart';
import 'package:s_inventory/pantallas/login.dart';
>>>>>>> b9b48df (carpetas)

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
<<<<<<< HEAD
        body: Recoverypassword()
=======
        body:SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iniciologo(),
              login(),
              

            ],
          ),
        ),
>>>>>>> b9b48df (carpetas)
      ),
    );
  }
}
