
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/services/producto_service.dart';
import 'package:s_inventory/services/ventas_servicios.dart';

import 'package:s_inventory/components/ventas/buscador_venta.dart';
import 'package:s_inventory/components/ventas/producto_venta_card.dart';
import 'package:s_inventory/components/ventas/carrito_venta.dart';
import 'package:s_inventory/components/ventas/resumen_venta.dart';
import 'package:s_inventory/components/ventas/estado_venta.dart';

class RegistrarVenta extends StatefulWidget {
  const RegistrarVenta({super.key});

  @override
  State<RegistrarVenta> createState() => _RegistrarVentaState();
}

class _RegistrarVentaState extends State<RegistrarVenta> {
  final _productoService = ProductoService();
  final _ventaService = VentaService();
  final _buscador = TextEditingController();

  List<Map<String, dynamic>> _productos = [];
  final Map<String, Map<String, dynamic>> _carrito = {};

  bool _cargando = true;
  bool _guardando = false;
  String? _error;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

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

  List<Map<String, dynamic>> get _filtrados {
    final texto = _busqueda.trim().toLowerCase();

    return _productos.where((producto) {
      return (producto['nombre']?.toString() ?? '')
          .toLowerCase()
          .contains(texto);
    }).toList();
  }

  double get _total => _carrito.values.fold<double>(
        0,
        (suma, item) =>
            suma +
            (double.tryParse('${item['precio']}') ?? 0) *
                (item['cantidad'] as int),
      );

  int get _unidades => _carrito.values.fold<int>(
        0,
        (suma, item) => suma + (item['cantidad'] as int),
      );

  String _dinero(num valor) {
    return '\$${valor.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => '.',
    )}';
  }

  void _mensaje(String texto) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _agregar(Map<String, dynamic> producto) {
    final id = producto['id_productos']?.toString();
    if (id == null) return;

    final stock = int.tryParse('${producto['stock']}') ?? 0;
    final cantidad = _carrito[id]?['cantidad'] as int? ?? 0;

    if (cantidad >= stock) {
      _mensaje('No hay suficiente stock disponible.');
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

    setState(() => _guardando = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final idUsuario = prefs.getString('id_usuario');

      if (idUsuario == null || idUsuario.isEmpty) {
        _mensaje('Inicia sesión nuevamente para registrar la venta.');
        return;
      }

      final productos = _carrito.entries.map((entrada) {
        return {
          'id_productos':
              int.tryParse(entrada.key) ?? entrada.key,
          'cantidad': entrada.value['cantidad'],
        };
      }).toList();

      await _ventaService.registrarVenta(
        idUsuario: idUsuario,
        productos: productos,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _mensaje('No se pudo registrar la venta: $e');
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: AppColors.fondo,
        foregroundColor: AppColors.textoPrincipal,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registrar venta',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
            Text(
              'Gestiona tus ventas',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white60,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar productos',
            onPressed: _cargando ? null : _cargarProductos,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _construirCuerpo(),
      bottomNavigationBar:
          _cargando || _error != null || _productos.isEmpty
              ? null
              : ResumenVenta(
                  totalFormateado: _dinero(_total),
                  guardando: _guardando,
                  carritoVacio: _carrito.isEmpty,
                  onConfirmar: _guardarVenta,
                ),
    );
  }

  Widget _construirCuerpo() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
        ),
      );
    }

    if (_error != null) {
      return EstadoVenta(
        icono: Icons.cloud_off_rounded,
        titulo: 'No se pudieron cargar los productos',
        descripcion:
            'Comprueba tu conexión e inténtalo nuevamente.',
        onReintentar: _cargarProductos,
      );
    }

    if (_productos.isEmpty) {
      return const EstadoVenta(
        icono: Icons.inventory_2_outlined,
        titulo: 'Tu inventario está vacío',
        descripcion:
            'Registra productos antes de crear una venta.',
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: BuscadorVenta(
            controller: _buscador,
            busqueda: _busqueda,
            onChanged: (valor) {
              setState(() => _busqueda = valor);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.secondary,
                size: 19,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Productos disponibles',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                '${_filtrados.length} productos',
                style: const TextStyle(
                  color: AppColors.textoSecundario,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _filtrados.isEmpty
              ? const Center(
                  child: Text(
                    'No se encontraron productos.',
                    style: TextStyle(color: Colors.white60),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: _filtrados.length,
                  itemBuilder: (context, index) {
                    final producto = _filtrados[index];
                    final id =
                        producto['id_productos']?.toString() ?? '';
                    final cantidad =
                        _carrito[id]?['cantidad'] as int? ?? 0;
                    final precio =
                        double.tryParse('${producto['precio']}') ?? 0;

                    return ProductoVentaCard(
                      producto: producto,
                      cantidad: cantidad,
                      precioFormateado: _dinero(precio),
                      onAgregar: () => _agregar(producto),
                      onCambiarCantidad: (cambio) {
                        _cambiarCantidad(id, cambio);
                      },
                    );
                  },
                ),
        ),
        if (_carrito.isNotEmpty)
          CarritoVenta(
            unidades: _unidades,
            cantidadProductos: _carrito.length,
            totalFormateado: _dinero(_total),
          ),
      ],
    );
  }
}
