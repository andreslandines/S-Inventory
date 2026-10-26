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
        backgroundColor: error
            ? const Color(0xFFB83232)
            : const Color(0xFF247A58),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stockBajo =
        _productos.where((p) => _stock(p) > 0 && _stock(p) <= 5).length;
    final agotados = _productos.where((p) => _stock(p) <= 0).length;

    return Scaffold(
      backgroundColor: AppColors.fondo,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _procesando ? null : _agregarProducto,
        backgroundColor: const Color(0xFF193A5B).withOpacity(0.95),
        foregroundColor: AppColors.accent,
        elevation: 0,
        splashColor: Colors.transparent,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: Colors.white.withOpacity(0.14),
          ),
        ),
        icon: const Icon(Icons.add_rounded, size: 25),
        label: const Text(
          'Agregar',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _cargarProductos,
          color: AppColors.accent,
          backgroundColor: const Color(0xFF193A5B),
          strokeWidth: 2.5,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            children: [
              // Encabezado
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.10),
                      ),
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      color: AppColors.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inventario',
                          style: Estilotextos.Titulos,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Administra los productos de tu negocio.',
                          style: Estilotextos.textoSecundario,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Buscador y filtros
              const BuscadorProductos(),

              const SizedBox(height: 22),

              // Estados de carga y error
              if (_cargando)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 35),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accent,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              else if (_error != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.10),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        color: Colors.white60,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: Estilotextos.textoNormal,
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          splashFactory: NoSplash.splashFactory,
                        ),
                        onPressed: _cargarProductos,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              else ...[
                // Resumen del inventario
                ResumenInventario(
                  totalProductos: _productos.length,
                  unidades: _unidades,
                  stockBajo: stockBajo,
                  agotados: agotados,
                ),

                const SizedBox(height: 26),

                // Título de productos
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Productos registrados',
                        style: Estilotextos.subtitulos,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7FDA)
                            .withOpacity(0.13),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF2E7FDA)
                              .withOpacity(0.25),
                        ),
                      ),
                      child: Text(
                        '${_productos.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Lista de productos
                if (_productos.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 32,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.09),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.white38,
                          size: 42,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No hay productos registrados.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
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