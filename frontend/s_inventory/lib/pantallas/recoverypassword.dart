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
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.secondary,
              width: 1.5,
            )
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(""),
                Text("S-Inventory", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 30)),
                const SizedBox(height: 20),
                  Center(
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text("Cambiar contraseña", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 26)),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Correo electronico',
                        labelStyle: TextStyle(color:  Colors.grey),
                        filled: true,
                        fillColor: AppColors.primary,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 2)
                        )
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Align(
                      alignment: AlignmentGeometry.centerRight,
                      child: TextButton(onPressed: () {}, 
                      child: const Text(
                        'Volver a enviar codigo', 
                        style: TextStyle(color: AppColors.fondoComponenteSeleccionado),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsetsGeometry.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.fondoComponenteSeleccionado,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(5),
                          side: const BorderSide(
                            color: Colors.white,
                            width: 0.5,
                          )
                        ),
                      ),
                      child: Text("Enviar codigo", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  Text(""),
                  Text(""),
                  Text(""),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Codigo',
                        labelStyle: TextStyle(color:  Colors.grey),
                        filled: true,
                        fillColor: AppColors.primary,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 2)
                        )
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsetsGeometry.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.fondoComponenteSeleccionado,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(5),
                          side: const BorderSide(
                            color: Colors.white,
                            width: 0.5,
                          )
                        ),
                      ),
                      child: Text("Verificar codigo", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  Text(""),
                  Text(""),
                ],
              ),
          ), 
          ),
        ),
      ),
    );
  }
}