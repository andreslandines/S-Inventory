import 'package:flutter/material.dart';
import 'package:s_inventory/components/login.dart';
import 'dart:async';
import 'package:s_inventory/core/colores.dart';


class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState(){
    super.initState();
    Timer(const Duration(seconds: 3), (){
      Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
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
              child: 
              Image(
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