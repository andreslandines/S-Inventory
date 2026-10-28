import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/core/estilostexto.dart';

class TarjetaProductoInventario extends StatefulWidget {
  final Map<String, dynamic> producto;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const TarjetaProductoInventario({
    super.key,
    required this.producto,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  State<TarjetaProductoInventario> createState() =>
      _TarjetaProductoInventarioState();
}

class _TarjetaProductoInventarioState
    extends State<TarjetaProductoInventario> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;

    final nombre = producto['nombre']?.toString() ?? 'Sin nombre';
    final categoriaCompleta =
        producto['categoria']?.toString() ?? '';
    final partesCategoria = categoriaCompleta.split(' - ');
    final categoria = partesCategoria.first.trim();

    final tipoProducto = partesCategoria.length > 1
        ? partesCategoria.sublist(1).join(' - ').trim()
        : '';

    final imagen = producto['imagen']?.toString() ?? '';
    final stock = int.tryParse('${producto['stock'] ?? 0}') ?? 0;
    final precio =
        double.tryParse('${producto['precio'] ?? 0}') ?? 0;

    final colorEstado = stock <= 0
        ? const Color(0xFFFF7777)
        : stock <= 5
            ? AppColors.accent
            : const Color(0xFF69D5A5);

    final estado = stock <= 0
        ? 'Agotado'
        : stock <= 5
            ? 'Stock bajo'
            : 'Disponible';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _expandido
              ? AppColors.secondary.withOpacity(0.45)
              : Colors.white.withOpacity(0.09),
        ),
      ),
      child: Column(
        children: [
          // Tarjeta compacta: solo muestra el nombre.
          InkWell(
            onTap: () {
              setState(() {
                _expandido = !_expandido;
              });
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 15,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.secondary,
                    size: 21,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Estilotextos.textoNormal.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expandido
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white70,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // Información que aparece al seleccionar el producto.
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _expandido
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          color: Colors.white.withOpacity(0.10),
                          height: 1,
                        ),
                        const SizedBox(height: 14),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: imagen.trim().isEmpty
                                  ? _imagenVacia()
                                  : Image.network(
                                      imagen,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _imagenVacia(),
                                    ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  if (categoria.isNotEmpty) ...[
                                    Text(
                                      'Categoría',
                                      style: Estilotextos.textoSecundario,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      tipoProducto.isEmpty
                                          ? categoria
                                          : '$categoria · $tipoProducto',
                                      style: Estilotextos.textoNormal,
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                  Text(
                                    'Precio',
                                    style: Estilotextos.textoSecundario,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '\$${precio.toStringAsFixed(0)}',
                                    style: Estilotextos.textoNormal.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.035),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.07),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.inventory_outlined,
                                color: Colors.white70,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Stock: $stock unidades',
                                  style: Estilotextos.textoNormal,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: colorEstado.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: colorEstado.withOpacity(0.25),
                                  ),
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
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: widget.onEditar,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.accent,
                                  side: BorderSide(
                                    color: AppColors.accent.withOpacity(0.4),
                                  ),
                                  backgroundColor:
                                      Colors.white.withOpacity(0.02),
                                  splashFactory:
                                      NoSplash.splashFactory,
                                  overlayColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                ),
                                label: const Text('Editar'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: widget.onEliminar,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      const Color(0xFFFF7777),
                                  side: BorderSide(
                                    color: const Color(0xFFFF7777)
                                        .withOpacity(0.4),
                                  ),
                                  backgroundColor:
                                      Colors.white.withOpacity(0.02),
                                  splashFactory:
                                      NoSplash.splashFactory,
                                  overlayColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                ),
                                label: const Text('Eliminar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _imagenVacia() {
    return Container(
      width: 90,
      height: 90,
      color: Colors.white.withOpacity(0.05),
      alignment: Alignment.center,
      child: const Icon(
        Icons.inventory_2_outlined,
        color: Colors.white54,
        size: 30,
      ),
    );
  }
}
