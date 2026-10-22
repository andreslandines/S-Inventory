
import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';

class ConfirmarEliminarProducto {
  static Future<bool> mostrar(
    BuildContext context,
    String nombre,
  ) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.fondoComponentes,
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Color(0xFFFF7777),
          size: 38,
        ),
        title: const Text(
          '¿Eliminar producto?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Seguro que deseas eliminar "$nombre"? '
          'Esta acción no se puede deshacer.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7777),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sí, eliminar'),
          ),
        ],
      ),
    );

    return resultado ?? false;
  }
}
