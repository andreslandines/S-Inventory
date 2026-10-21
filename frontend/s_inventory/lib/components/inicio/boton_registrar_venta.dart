import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';

class BotonRegistrarVenta extends StatelessWidget {
  final VoidCallback onPressed;

  const BotonRegistrarVenta({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.point_of_sale),
        label: const Text('Registrar venta diaria'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.fondo,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}