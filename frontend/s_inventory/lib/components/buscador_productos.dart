import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/services/producto_service.dart';

class BuscadorProductos extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>>? onProductoTap;

  const BuscadorProductos({
    super.key,
    this.onProductoTap,
  });

  @override
  State<BuscadorProductos> createState() => _BuscadorProductosState();
}

class _BuscadorProductosState extends State<BuscadorProductos> {
  final ProductoService _productoService = ProductoService();
  final TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> productos = [];
  String busqueda = '';
  bool cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    setState(() {
      cargando = true;
    });

    try {
      final datos = await _productoService.obtenerProductos();

      if (!mounted) return;

      setState(() {
        productos = datos;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        productos = [];
        cargando = false;
      });
    }
  }

  List<Map<String, dynamic>> get _resultados {
    final texto = busqueda.trim().toLowerCase();

    if (texto.isEmpty) {
      return [];
    }

    return productos.where((producto) {
      final nombre = (producto['nombre'] ?? '')
          .toString()
          .toLowerCase();

      final categoria = (producto['categoria'] ?? '')
          .toString()
          .toLowerCase();

      return nombre.contains(texto) ||
          categoria.contains(texto);
    }).toList();
  }

  void _limpiarBusqueda() {
    _controller.clear();

    setState(() {
      busqueda = '';
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultados = _resultados;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          onChanged: (valor) {
            setState(() {
              busqueda = valor;
            });
          },
          style: const TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'Buscar productos...',
            hintStyle: const TextStyle(
              color: Colors.white60,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.white70,
            ),
            suffixIcon: busqueda.isNotEmpty
                ? IconButton(
                    onPressed: _limpiarBusqueda,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white70,
                    ),
                  )
                : null,
            filled: true,
            fillColor: AppColors.fondo,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.white24,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.white24,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.white,
                width: 1.5,
              ),
            ),
          ),
        ),

        if (cargando)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          ),

        if (!cargando && busqueda.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: resultados.isEmpty
                ? const Text(
                    'No se encontraron productos',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  )
                : Column(
                    children: resultados.map((producto) {
                      final nombre =
                          producto['nombre']?.toString() ??
                              'Sin nombre';

                      final precio =
                          producto['precio']?.toString() ??
                              'No disponible';

                      final stock =
                          producto['stock']?.toString() ??
                              'No disponible';

                      final categoria =
                          producto['categoria']?.toString() ??
                              '';

                      final imagen =
                          producto['imagen']?.toString() ??
                              '';

                      return Card(
                        color: Colors.white.withOpacity(0.08),
                        margin: const EdgeInsets.only(
                          bottom: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          onTap: widget.onProductoTap == null
                              ? null
                              : () => widget.onProductoTap!(
                                    producto,
                                  ),
                          leading: _imagenProducto(imagen),
                          title: Text(
                            nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Precio: $precio\n'
                            'Stock: $stock'
                            '${categoria.isNotEmpty ? '\n$categoria' : ''}',
                            style: const TextStyle(
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
      ],
    );
  }

  Widget _imagenProducto(String imagen) {
    if (imagen.isEmpty) {
      return const CircleAvatar(
        backgroundColor: Colors.white12,
        child: Icon(
          Icons.inventory_2_outlined,
          color: Colors.white,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imagen,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return const SizedBox(
            width: 50,
            height: 50,
            child: Icon(
              Icons.inventory_2_outlined,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
