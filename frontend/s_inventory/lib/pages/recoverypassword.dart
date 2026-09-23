import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';

class Recoverypassword extends StatefulWidget {
  const Recoverypassword({super.key});

  @override
  State<Recoverypassword> createState() => _RecoverypasswordState();
}

class _RecoverypasswordState extends State<Recoverypassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.9,
          heightFactor: 0.9,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text("S-Inventory", style: TextStyle(color: Colors.white,)),
          ),
        ),
      ),
    );
  }
}