import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/core/estilostexto.dart';


class iniciologo extends StatefulWidget {
  const iniciologo({super.key});

  @override
  State<iniciologo> createState() => _iniciologoState();
}

class _iniciologoState extends State<iniciologo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.primary,
         child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: 
              Image(
                image: AssetImage("assets/images/logo.png"),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            Text("S-Inventory", style:Estilotextos.Titulos),

          ],
         ),
      ),
    );
  }
}