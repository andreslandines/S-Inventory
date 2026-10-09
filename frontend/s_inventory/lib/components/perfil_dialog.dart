import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/pages/perfil.dart';

void mostrarPerfil({
  required BuildContext context,
  required String nombre,
  required String correo,
  required VoidCallback cerrarSesion,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
         backgroundColor: AppColors.fondo.withOpacity(0.60),
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: Colors.white.withOpacity(0.18),            width: 2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person_rounded,
                color: AppColors.fondo,
                size: 38,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              nombre,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              correo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(dialogContext);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Perfil(),
                    ),
                  );
                },
                icon: const Icon(Icons.person_rounded,),
                label: const Text('Perfil'),
                 style: ElevatedButton.styleFrom(
                  backgroundColor:Colors.white.withOpacity(0.08),
                  foregroundColor: Colors.white,
                ),
              ),
              ),
              

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  cerrarSesion();
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Cerrar sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 245, 0, 0).withOpacity(0.46),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}