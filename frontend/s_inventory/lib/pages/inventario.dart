import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/core/estilostexto.dart';
import 'package:s_inventory/services/producto_service.dart';
import 'package:s_inventory/components/resumen_inventario.dart';
import 'package:s_inventory/components/tarjeta_producto.dart';
import 'package:s_inventory/components/formulario.dart';

class Inventario extends StatefulWidget {
  const Inventario({super.key});

  @override
  State<Inventario> createState() => _InventarioState();
}

class _InventarioState extends State<Inventario> {
  final _service = ProductoService();
  List<Map<String, dynamic>> _productos = [];
  bool _cargando = true, _guardando = false;
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
      _productos = await _service.obtenerProductos();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  int _stock(Map<String, dynamic> p) =>
      int.tryParse('${p['stock'] ?? 0}') ?? 0;

  int get _unidades =>
      _productos.fold(0, (total, p) => total + _stock(p));

  Future<void> _agregarProducto() async {
    final datos = await FormularioProducto.mostrar(context);
    if (!mounted || datos == null) return;

    setState(() => _guardando = true);

    try {
      final XFile imagen = datos['imagen'];
      final bytes = await imagen.readAsBytes();

      await _service.crearProducto(
        nombre: datos['nombre'],
        descripcion: datos['descripcion'],
        precio: datos['precio'],
        categoria: datos['categoria'],
        stock: datos['stock'],
        imagenBytes: bytes,
        nombreImagen: imagen.name,
      );

      if (!mounted) return;
      _mensaje('Producto registrado correctamente.');
      await _cargarProductos();
    } catch (e) {
      if (mounted) {
        _mensaje(e.toString().replaceFirst('Exception: ', ''), error: true);
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
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
    final stockBajo = _productos.where((p) =>
        _stock(p) > 0 && _stock(p) <= 5).length;
    final agotados = _productos.where((p) => _stock(p) <= 0).length;

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
                color: const Color.fromARGB(255, 164, 161, 161).withOpacity(0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12, width: 1),
        boxShadow: [
          BoxShadow(
                  color: Colors.white.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0,20),
          ),
        ],
      ),
      child: Scaffold(
      
        
        backgroundColor: AppColors.fondo,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _guardando ? null : _agregarProducto,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.fondo,
          icon: const Icon(Icons.add),
          label: Text(_guardando ? 'Guardando...' : 'Agregar producto'),
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
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TarjetaProductoInventario(producto: p),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}