
import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';

class ProductoVentaCard extends StatelessWidget {
  final Map<String, dynamic> producto;
  final int cantidad;
  final String precioFormateado;
  final VoidCallback onAgregar;
  final ValueChanged<int> onCambiarCantidad;

  const ProductoVentaCard({
    super.key,
    required this.producto,
    required this.cantidad,
    required this.precioFormateado,
    required this.onAgregar,
    required this.onCambiarCantidad,
  });

  @override
  Widget build(BuildContext context) {
    final imagen = producto['imagen']?.toString() ?? '';
    final stock = int.tryParse('${producto['stock']}') ?? 0;
    final minimo =
        int.tryParse('${producto['stock_minimo']}') ?? 0;
    final agotado = stock <= 0;
    final stockBajo = !agotado && stock <= minimo;

    final colorStock = agotado
        ? AppColors.error
        : stockBajo
            ? AppColors.advertencia
            : AppColors.exito;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fondoComponentes,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cantidad > 0
              ? AppColors.secondary.withOpacity(0.7)
              : AppColors.bordeOscuro,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Container(
              width: 68,
              height: 72,
              color: AppColors.fondo,
              child: imagen.isEmpty
                  ? const Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.secondary,
                      size: 30,
                    )
                  : Image.network(
                      imagen,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.secondary,
                        size: 30,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${producto['nombre'] ?? 'Producto'}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  precioFormateado,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      agotado
                          ? Icons.cancel_outlined
                          : stockBajo
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle_outline,
                      size: 14,
                      color: colorStock,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        agotado
                            ? 'Agotado'
                            : 'Stock: $stock${stockBajo ? ' · Bajo' : ''}',
                        style: TextStyle(
                          color: colorStock,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (cantidad == 0)
            IconButton.filled(
              onPressed: agotado ? null : onAgregar,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.bordeOscuro,
              ),
              icon: const Icon(Icons.add_rounded),
            )
          else
            Column(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => onCambiarCantidad(1),
                  icon: const Icon(
                    Icons.add_circle_rounded,
                    color: AppColors.accent,
                  ),
                ),
                Text(
                  '$cantidad',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => onCambiarCantidad(-1),
                  icon: const Icon(
                    Icons.remove_circle_outline_rounded,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
