
import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';

class CarritoVenta extends StatelessWidget {
  final int unidades;
  final int cantidadProductos;
  final String totalFormateado;

  const CarritoVenta({
    super.key,
    required this.unidades,
    required this.cantidadProductos,
    required this.totalFormateado,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.fondoComponentes,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bordeOscuro),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shopping_basket_outlined,
            color: AppColors.accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$unidades ${unidades == 1 ? 'unidad' : 'unidades'}'
              ' · $cantidadProductos productos',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            totalFormateado,
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}
