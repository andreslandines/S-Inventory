import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';

class EncabezadoReportes extends StatelessWidget {
  final VoidCallback onActualizar;

  const EncabezadoReportes({
    super.key,
    required this.onActualizar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withOpacity(0.25),
            AppColors.fondoComponentes.withOpacity(0.65),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.20),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              color: AppColors.accent,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reportes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Resumen de tu inventario y ventas',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onActualizar,
            tooltip: 'Actualizar reportes',
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}