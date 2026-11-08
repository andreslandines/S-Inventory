
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:s_inventory/core/colores.dart';

class ProductoVentaCard extends StatefulWidget {
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
  State<ProductoVentaCard> createState() => _ProductoVentaCardState();
}

class _ProductoVentaCardState extends State<ProductoVentaCard> {
  late final TextEditingController _cantidadController;
  late final FocusNode _cantidadFocus;

  @override
  void initState() {
    super.initState();

    _cantidadController = TextEditingController(
      text: '${widget.cantidad}',
    );

    _cantidadFocus = FocusNode();
  }

  @override
  void didUpdateWidget(covariant ProductoVentaCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.cantidad != widget.cantidad &&
        !_cantidadFocus.hasFocus) {
      _cantidadController.text = '${widget.cantidad}';
    }
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _cantidadFocus.dispose();
    super.dispose();
  }

  void _actualizarCantidad(String valor) {
    final nuevaCantidad = int.tryParse(valor);
    final stock = int.tryParse('${widget.producto['stock']}') ?? 0;

    if (nuevaCantidad == null || nuevaCantidad < 1) {
      _cantidadController.text = '${widget.cantidad}';
      return;
    }

    if (nuevaCantidad > stock) {
      _cantidadController.text = '${widget.cantidad}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Solo hay $stock unidades disponibles.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    final diferencia = nuevaCantidad - widget.cantidad;

    if (diferencia != 0) {
      widget.onCambiarCantidad(diferencia);
    }

    _cantidadController.text = '$nuevaCantidad';
  }

  @override
  Widget build(BuildContext context) {
    final imagen = widget.producto['imagen']?.toString() ?? '';
    final nombre = widget.producto['nombre']?.toString() ?? 'Producto';

    final descripcion =
        widget.producto['descripcion']?.toString().trim() ?? '';

    final stock = int.tryParse('${widget.producto['stock']}') ?? 0;
    final minimo =
        int.tryParse('${widget.producto['stock_minimo']}') ?? 0;

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
          color: widget.cantidad > 0
              ? AppColors.secondary.withOpacity(0.7)
              : AppColors.bordeOscuro,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Container(
              width: 68,
              height: 78,
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
                  nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),

                if (descripcion.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    descripcion,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],

                const SizedBox(height: 7),

                Text(
                  widget.precioFormateado,
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

          if (widget.cantidad == 0)
            IconButton.filled(
              onPressed: agotado ? null : widget.onAgregar,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.bordeOscuro,
              ),
              icon: const Icon(Icons.add_rounded),
            )
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: widget.cantidad >= stock
                      ? null
                      : () => widget.onCambiarCantidad(1),
                  icon: const Icon(
                    Icons.add_circle_rounded,
                    color: AppColors.accent,
                  ),
                ),

                // CANTIDAD EDITABLE CON EL TECLADO
                SizedBox(
                  width: 48,
                  height: 38,
                  child: TextField(
                    controller: _cantidadController,
                    focusNode: _cantidadFocus,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 5,
                      ),
                      filled: true,
                      fillColor: AppColors.fondo,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: BorderSide(
                          color: AppColors.accent.withOpacity(0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: BorderSide(
                          color: AppColors.accent.withOpacity(0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: const BorderSide(
                          color: AppColors.accent,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onSubmitted: _actualizarCantidad,
                    onTapOutside: (_) {
                      _cantidadFocus.unfocus();
                      _actualizarCantidad(_cantidadController.text);
                    },
                  ),
                ),

                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => widget.onCambiarCantidad(-1),
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
