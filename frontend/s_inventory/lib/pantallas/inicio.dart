import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/core/estilostexto.dart';


class inicio extends StatefulWidget {
  const inicio({super.key});

  @override
  State<inicio> createState() => _inicioState();
}

class _inicioState extends State<inicio> {
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
            Text("S-Inventory", style:Estilotextos.Titulos),
            Image(
              image: AssetImage("assets/images/.jpg"),
              width: 150,
              height: 200,
              fit: BoxFit.cover,
            ),
          ],
         ),
      ),
    );
  }
}