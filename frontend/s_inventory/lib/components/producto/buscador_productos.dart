
import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/components/producto/formulario.dart';
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
  final _service = ProductoService();
  final _controller = TextEditingController();

  List<Map<String, dynamic>> productos = [];
  String busqueda = '';
  String categoriaSeleccionada = 'Todas las categorías';
  bool cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    setState(() => cargando = true);

    try {
      final datos = await _service.obtenerProductos();
      if (!mounted) return;
      setState(() => productos = datos);
    } catch (_) {
      if (!mounted) return;
      setState(() => productos = []);
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  String _categoria(Map<String, dynamic> producto) {
    final valor = producto['categoria']?.toString().trim() ?? '';
    if (valor.isEmpty) return 'Sin categoría';
    return valor.split(' - ').first.trim();
  }

  List<String> get _categorias {
  return [
    'Todas las categorías',
    ...FormularioProducto.categorias.keys,
  ];
}

  List<Map<String, dynamic>> get _resultados {
    final texto = busqueda.trim().toLowerCase();

    if (texto.isEmpty &&
        categoriaSeleccionada == 'Todas las categorías') {
      return [];
    }

    return productos.where((p) {
      final nombre = (p['nombre'] ?? '').toString().toLowerCase();
      final categoria = (p['categoria'] ?? '').toString().toLowerCase();

      final coincideTexto = texto.isEmpty ||
          nombre.contains(texto) ||
          categoria.contains(texto);

     final coincideCategoria =
    categoriaSeleccionada == 'Todas las categorías' ||
    _categoria(p).toLowerCase() ==
        categoriaSeleccionada.toLowerCase();

      return coincideTexto && coincideCategoria;
    }).toList();
  }

  void _seleccionarCategoria(String categoria) {
    setState(() => categoriaSeleccionada = categoria);
  }

  void _limpiarBusqueda() {
    _controller.clear();
    setState(() => busqueda = '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultados = _resultados;
    final categorias = _categorias;
    final filtroActivo =
        categoriaSeleccionada != 'Todas las categorías';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (valor) => setState(() => busqueda = valor),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar productos...',
                  hintStyle: const TextStyle(color: Colors.white60),
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
                    vertical: 14,
                    horizontal: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.accent,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              tooltip: 'Filtrar por categoría',
              initialValue: categoriaSeleccionada,
              color: AppColors.fondo.withOpacity(0.90),
              icon: Icon(
                Icons.filter_list_rounded,
                color: filtroActivo ? AppColors.accent : Colors.white,
                size: 28,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: _seleccionarCategoria,
              itemBuilder: (context) => categorias.map((categoria) {
                final seleccionada = categoria == categoriaSeleccionada;

                return PopupMenuItem<String>(
                  value: categoria,
                  child: Row(
                    children: [
                      Icon(
                        seleccionada
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: seleccionada
                            ? AppColors.accent
                            : Colors.white70,
                        size: 19,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          categoria,
                          style: TextStyle(
                            color: seleccionada
                                ? AppColors.accent
                                : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        if (filtroActivo)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Categoría: $categoriaSeleccionada',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _seleccionarCategoria(
                    'Todas las categorías',
                  ),
                  child: const Text(
                    'Quitar filtro',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
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
        if (!cargando &&
            (busqueda.trim().isNotEmpty || filtroActivo))
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: resultados.isEmpty
                ? const Text(
                    'No se encontraron productos con esos filtros.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  )
                : Column(
                    children: resultados.map((p) {
                      final imagen = p['imagen']?.toString() ?? '';
                      final categoria = p['categoria']?.toString() ?? '';

                      return Card(
                        color: Colors.white.withOpacity(0.08),
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          onTap: widget.onProductoTap == null
                              ? null
                              : () => widget.onProductoTap!(p),
                          leading: _imagenProducto(imagen),
                          title: Text(
                            p['nombre']?.toString() ?? 'Sin nombre',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Precio: ${p['precio'] ?? 'No disponible'}\n'
                            'Stock: ${p['stock'] ?? 'No disponible'}'
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
        child: Icon(Icons.inventory_2_outlined, color: Colors.white),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imagen,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox(
          width: 50,
          height: 50,
          child: Icon(
            Icons.inventory_2_outlined,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
