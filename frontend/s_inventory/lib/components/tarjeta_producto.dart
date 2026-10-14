
import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/core/estilostexto.dart';

class TarjetaProductoInventario extends StatelessWidget {
  final Map<String, dynamic> producto;

  const TarjetaProductoInventario({
    super.key,
    required this.producto,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = producto['nombre']?.toString() ?? 'Sin nombre';
    final categoria = producto['categoria']?.toString() ?? '';
    final imagen = producto['imagen']?.toString() ?? '';

    final stock =
        int.tryParse('${producto['stock'] ?? 0}') ?? 0;

    final precio =
        double.tryParse('${producto['precio'] ?? 0}') ?? 0;

    final Color colorEstado = stock <= 0
        ? const Color(0xFFFF7777)
        : stock <= 5
            ? AppColors.accent
            : const Color(0xFF69D5A5);

    final String estado = stock <= 0
        ? 'Agotado'
        : stock <= 5
            ? 'Stock bajo'
            : 'Disponible';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fondoComponentes,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imagen.isEmpty
                ? _imagenVacia()
                : Image.network(
                    imagen,
                    width: 65,
                    height: 65,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagenVacia(),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Estilotextos.textoNormal.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (categoria.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    categoria,
                    style: Estilotextos.textoSecundario,
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  'Precio: \$${precio.toStringAsFixed(0)}',
                  style: Estilotextos.textoSecundario,
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 7,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Stock: $stock',
                      style: Estilotextos.textoSecundario,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colorEstado.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        estado,
                        style: TextStyle(
                          color: colorEstado,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagenVacia() {
    return Container(
      width: 65,
      height: 65,
      color: Colors.white.withOpacity(0.07),
      child: const Icon(
        Icons.inventory_2_outlined,
        color: Colors.white70,
        size: 28,
      ),
    );
  }
}
