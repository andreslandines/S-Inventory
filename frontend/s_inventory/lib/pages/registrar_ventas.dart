
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/services/producto_service.dart';
import 'package:s_inventory/services/ventas_servicios.dart';

class RegistrarVenta extends StatefulWidget {
  const RegistrarVenta({super.key});

  @override
  State<RegistrarVenta> createState() => _RegistrarVentaState();
}

class _RegistrarVentaState extends State<RegistrarVenta> {
  final _productoService = ProductoService();
  final _ventaService = VentaService();

  List<Map<String, dynamic>> _productos = [];
  final Map<String, Map<String, dynamic>> _carrito = {};

  bool _cargando = true;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    try {
      final datos = await _productoService.obtenerProductos();
      if (!mounted) return;

      setState(() {
        _productos = datos;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  double get _total => _carrito.values.fold<double>(
        0,
        (suma, item) =>
            suma +
            (double.tryParse(item['precio'].toString()) ?? 0) *
                (item['cantidad'] as int),
      );

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  String _dinero(num valor) => '\$${valor.toStringAsFixed(0)}';

  void _agregar(Map<String, dynamic> producto) {
    final id = producto['id_productos']?.toString();
    if (id == null) return;

    final stock = int.tryParse('${producto['stock']}') ?? 0;
    final cantidad = _carrito[id]?['cantidad'] as int? ?? 0;

    if (cantidad >= stock) {
      _mensaje('No hay suficiente stock.');
      return;
    }

    setState(() {
      _carrito[id] = {...producto, 'cantidad': cantidad + 1};
    });
  }

  void _cambiarCantidad(String id, int cambio) {
    final item = _carrito[id];
    if (item == null) return;

    final nueva = (item['cantidad'] as int) + cambio;
    final stock = int.tryParse('${item['stock']}') ?? 0;

    if (nueva > stock) {
      _mensaje('La cantidad supera el stock disponible.');
      return;
    }

    setState(() {
      if (nueva <= 0) {
        _carrito.remove(id);
      } else {
        item['cantidad'] = nueva;
      }
    });
  }

  Future<void> _guardarVenta() async {
    if (_carrito.isEmpty || _guardando) return;

    final prefs = await SharedPreferences.getInstance();
    final idUsuario = prefs.getString('id_usuario');

    if (idUsuario == null || idUsuario.isEmpty) {
      _mensaje('No se encontró el ID del usuario. Inicia sesión nuevamente.');
      return;
    }

    setState(() => _guardando = true);

    try {
      final productos = _carrito.entries.map((entrada) {
        return {
          'id_productos': int.tryParse(entrada.key) ?? entrada.key,
          'cantidad': entrada.value['cantidad'],
        };
      }).toList();

      await _ventaService.registrarVenta(
        idUsuario: idUsuario,
        productos: productos,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venta registrada correctamente.')),
      );
    } catch (e) {
      _mensaje(e.toString());
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: AppColors.fondo,
        foregroundColor: Colors.white,
        title: const Text('Registrar venta'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Selecciona los productos vendidos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Agrega productos y ajusta sus cantidades.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    ..._productos.map(_tarjetaProducto),
                    if (_carrito.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      const Text(
                        'Tu venta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ..._carrito.entries.map(_lineaCarrito),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.fondoComponentes,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      _dinero(_total),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _carrito.isEmpty || _guardando
                    ? null
                    : _guardarVenta,
                icon: _guardando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(_guardando ? 'Guardando...' : 'Confirmar venta'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tarjetaProducto(Map<String, dynamic> producto) {
    final imagen = producto['imagen']?.toString() ?? '';
    final stock = int.tryParse('${producto['stock']}') ?? 0;

    return Card(
      color: AppColors.fondoComponentes,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imagen.isEmpty
              ? const Icon(Icons.inventory_2, color: Colors.white70)
              : Image.network(
                  imagen,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.inventory_2,
                    color: Colors.white70,
                  ),
                ),
        ),
        title: Text(
          '${producto['nombre'] ?? 'Producto'}',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          '${_dinero(double.tryParse('${producto['precio']}') ?? 0)} · Stock: $stock',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: IconButton(
          onPressed: stock > 0 ? () => _agregar(producto) : null,
          icon: const Icon(
            Icons.add_circle,
            color: AppColors.secondary,
          ),
        ),
      ),
    );
  }

  Widget _lineaCarrito(
    MapEntry<String, Map<String, dynamic>> entrada,
  ) {
    final item = entrada.value;
    final cantidad = item['cantidad'] as int;
    final precio = double.tryParse('${item['precio']}') ?? 0;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${item['nombre']}\n${_dinero(precio * cantidad)}',
              style: const TextStyle(color: Colors.white, height: 1.5),
            ),
          ),
          IconButton(
            onPressed: () => _cambiarCantidad(entrada.key, -1),
            icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
          ),
          Text('$cantidad', style: const TextStyle(color: Colors.white)),
          IconButton(
            onPressed: () => _cambiarCantidad(entrada.key, 1),
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
