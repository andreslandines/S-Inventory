
import 'package:flutter/material.dart';

import 'package:s_inventory/components/buscador_productos.dart';
import 'package:s_inventory/components/confirmar_eliminar_producto.dart';
import 'package:s_inventory/components/formulario_editar_producto.dart';
import 'package:s_inventory/components/resumen_inventario.dart';
import 'package:s_inventory/components/tarjeta_producto.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/core/estilostexto.dart';
import 'package:s_inventory/pages/registrar_producto.dart';
import 'package:s_inventory/services/producto_service.dart';

class Inventario extends StatefulWidget {
  const Inventario({super.key});

  @override
  State<Inventario> createState() => _InventarioState();
}

class _InventarioState extends State<Inventario> {
  final _service = ProductoService();

  List<Map<String, dynamic>> _productos = [];
  bool _cargando = true;
  bool _procesando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final productos = await _service.obtenerProductos();
      if (mounted) setState(() => _productos = productos);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  int _stock(Map<String, dynamic> p) =>
      int.tryParse('${p['stock'] ?? 0}') ?? 0;

  int get _unidades =>
      _productos.fold(0, (total, p) => total + _stock(p));

  Future<void> _agregarProducto() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const RegistrarProductoPage(),
      ),
    );

    if (resultado == true && mounted) {
      await _cargarProductos();
    }
  }

  Future<void> _editar(Map<String, dynamic> producto) async {
    final id = producto['id_productos']?.toString();

    if (id == null || id.isEmpty) {
      _mensaje('No se encontró el ID del producto.', error: true);
      return;
    }

    final datos = await FormularioEditarProducto.mostrar(
      context,
      producto,
    );

    if (datos == null || !mounted) return;

    setState(() => _procesando = true);

    try {
      await _service.actualizarProducto(
        id: id,
        nombre: datos['nombre']!,
        descripcion: datos['descripcion']!,
        precio: datos['precio']!,
        categoria: datos['categoria']!,
        stock: datos['stock']!,
      );

      if (!mounted) return;
      _mensaje('Producto actualizado correctamente.');
      await _cargarProductos();
    } catch (e) {
      if (mounted) {
        _mensaje(
          e.toString().replaceFirst('Exception: ', ''),
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  Future<void> _eliminar(Map<String, dynamic> producto) async {
    final id = producto['id_productos']?.toString();
    final nombre = producto['nombre']?.toString() ?? 'este producto';

    if (id == null || id.isEmpty) {
      _mensaje('No se encontró el ID del producto.', error: true);
      return;
    }

    final confirmar = await ConfirmarEliminarProducto.mostrar(
      context,
      nombre,
    );

    if (!confirmar || !mounted) return;

    setState(() => _procesando = true);

    try {
      await _service.eliminarProducto(id);

      if (!mounted) return;
      _mensaje('Producto eliminado correctamente.');
      await _cargarProductos();
    } catch (e) {
      if (mounted) {
        _mensaje(
          e.toString().replaceFirst('Exception: ', ''),
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  void _mensaje(String texto, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: error ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stockBajo =
        _productos.where((p) => _stock(p) > 0 && _stock(p) <= 5).length;
    final agotados = _productos.where((p) => _stock(p) <= 0).length;

    return  Scaffold( 
        backgroundColor: AppColors.fondo,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _procesando ? null : _agregarProducto,
          backgroundColor: const Color.fromARGB(255, 25, 31, 51).withOpacity(0.8),
          foregroundColor: AppColors.borde,
          label: const Text(''),
          icon: const Icon(Icons.add),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _cargarProductos,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Inventario', style: Estilotextos.Titulos),
                const SizedBox(height: 6),
                Text(
                  'Administra los productos de tu negocio.',
                  style: Estilotextos.textoSecundario,
                ),
                const SizedBox(height: 20),
                const BuscadorProductos(),
                const SizedBox(height: 20),
                if (_cargando)
                  const Center(child: CircularProgressIndicator())
                else if (_error != null)
                  Column(
                    children: [
                      Text(_error!, style: Estilotextos.textoNormal),
                      TextButton(
                        onPressed: _cargarProductos,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  )
                else ...[
                  ResumenInventario(
                    totalProductos: _productos.length,
                    unidades: _unidades,
                    stockBajo: stockBajo,
                    agotados: agotados,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Productos registrados (${_productos.length})',
                    style: Estilotextos.subtitulos,
                  ),
                  const SizedBox(height: 22),
                  if (_productos.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No hay productos registrados.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
                  else
                    ..._productos.map(
                      (p) => TarjetaProductoInventario(
                        producto: p,
                        onEditar: () => _editar(p),
                        onEliminar: () => _eliminar(p),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
    );
  }
}
