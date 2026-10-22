import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';

class TarjetaProductoInicio extends StatelessWidget {
  final Map<String, dynamic> producto;

  const TarjetaProductoInicio({
    super.key,
    required this.producto,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = producto['nombre']?.toString() ?? 'Producto';
    final precio = double.tryParse(
          producto['precio']?.toString() ?? '',
        ) ??
        0;
    final imagen = producto['imagen']?.toString() ?? '';

    return Container(
      width: 155,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fondoComponentes,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imagen.isNotEmpty
                ? Image.network(
                    imagen,
                    height: 95,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _sinImagen(),
                  )
                : _sinImagen(),
          ),
          const SizedBox(height: 10),
          Text(
            nombre,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '\$${precio.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sinImagen() {
    return Container(
      height: 95,
      width: double.infinity,
      color: AppColors.primary,
      child: const Icon(
        Icons.inventory_2_outlined,
        color: Colors.white70,
        size: 34,
      ),
    );
  }
}