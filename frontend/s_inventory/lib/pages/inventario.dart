
import 'package:flutter/material.dart';

import 'package:s_inventory/components/producto/buscador_productos.dart';
import 'package:s_inventory/components/producto/confirmar_eliminar_producto.dart';
import 'package:s_inventory/components/producto/formulario_editar_producto.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/core/estilostexto.dart';
import 'package:s_inventory/pages/registrar_producto.dart';
import 'package:s_inventory/pages/registrar_entrada_page.dart';
import 'package:s_inventory/pages/lotes_page.dart';
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

  // =====================================================
  // CARGAR PRODUCTOS
  // =====================================================

  Future<void> _cargarProductos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final productos = await _service.obtenerProductos();

      if (mounted) {
        setState(() => _productos = productos);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  // =====================================================
  // CÁLCULOS DE INVENTARIO
  // =====================================================

  int _stock(Map<String, dynamic> p) =>
      int.tryParse('${p['stock'] ?? 0}') ?? 0;

  int get _unidades =>
      _productos.fold(0, (total, p) => total + _stock(p));

  int get _stockBajo => _productos
      .where((p) => _stock(p) > 0 && _stock(p) <= 5)
      .length;

  int get _agotados =>
      _productos.where((p) => _stock(p) <= 0).length;

  // =====================================================
  // AGREGAR PRODUCTO
  // =====================================================

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

  // =====================================================
  // REGISTRAR ENTRADA DE INVENTARIO
  // =====================================================

  Future<void> _registrarEntrada() async {
    if (_procesando || _cargando) return;

    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const RegistrarEntradaPage(),
      ),
    );

    if (resultado == true && mounted) {
      await _cargarProductos();

      if (mounted) {
        _mensaje('Inventario actualizado correctamente.');
      }
    }
  }

  // =====================================================
  // CONSULTAR LOTES
  // =====================================================

  Future<void> _consultarLotes() async {
    if (_procesando) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LotesPage(),
      ),
    );

    if (mounted) {
      await _cargarProductos();
    }
  }

  // =====================================================
  // EDITAR PRODUCTO
  // =====================================================

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
        nombre: datos['nombre'],
        descripcion: datos['descripcion'],
        precio: datos['precio'],
        categoria: datos['categoria'],
        codigoBarras: datos['codigoBarras'] as String?,
        imagenArchivo: datos['imagenArchivo'],
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
      if (mounted) {
        setState(() => _procesando = false);
      }
    }
  }

  // =====================================================
  // ELIMINAR PRODUCTO
  // =====================================================

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
      if (mounted) {
        setState(() => _procesando = false);
      }
    }
  }

  // =====================================================
  // MENSAJES
  // =====================================================

  void _mensaje(String texto, {bool error = false}) {
    if (!mounted) return;

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

  // =====================================================
  // FILTRAR PRODUCTOS
  // =====================================================

  List<Map<String, dynamic>> _filtrarProductos(String tipo) {
    switch (tipo) {
      case 'unidades':
        return _productos.where((p) => _stock(p) > 0).toList();

      case 'bajo':
        return _productos
            .where((p) => _stock(p) > 0 && _stock(p) <= 5)
            .toList();

      case 'agotados':
        return _productos.where((p) => _stock(p) <= 0).toList();

      default:
        return List<Map<String, dynamic>>.from(_productos);
    }
  }

  // =====================================================
  // INFORMACIÓN DEL PRODUCTO
  // =====================================================

  String _categoria(Map<String, dynamic> producto) {
    final valor = producto['categoria']?.toString().trim() ?? '';

    if (valor.isEmpty) return 'Sin categoría';

    return valor.replaceAll(' - ', ' · ');
  }

  String _precio(Map<String, dynamic> producto) {
    final precio = double.tryParse(
          '${producto['precio'] ?? 0}',
        ) ??
        0;

    return '\$${precio.toStringAsFixed(0)}';
  }

  // =====================================================
  // TARJETA DE PRODUCTO
  // =====================================================

  Widget _tarjetaProducto(Map<String, dynamic> producto) {
    final nombre =
        producto['nombre']?.toString() ?? 'Sin nombre';

    final imagen =
        producto['imagen']?.toString().trim() ?? '';

    final stock = _stock(producto);

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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imagen.isNotEmpty
                    ? Image.network(
                        imagen,
                        width: 82,
                        height: 82,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagenVacia(),
                      )
                    : _imagenVacia(),
              ),

              const SizedBox(width: 13),

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
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      _categoria(producto),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Text(
                      _precio(producto),
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
                          Icons.inventory_2_outlined,
                          color: colorEstado,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Stock: $stock unidades',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 5),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
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
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _procesando ? null : () => _editar(producto),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 17,
                  ),
                  label: const Text('Editar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: BorderSide(
                      color: AppColors.accent.withOpacity(0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _procesando ? null : () => _eliminar(producto),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 17,
                  ),
                  label: const Text('Eliminar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF7777),
                    side: BorderSide(
                      color: const Color(0xFFFF7777).withOpacity(0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imagenVacia() {
    return Container(
      width: 82,
      height: 82,
      color: Colors.white.withOpacity(0.06),
      alignment: Alignment.center,
      child: const Icon(
        Icons.inventory_2_outlined,
        color: Colors.white54,
        size: 30,
      ),
    );
  }

  // =====================================================
  // DETALLE DE PRODUCTOS
  // =====================================================

  Future<void> _abrirDetalle(
    String tipo,
    String titulo,
    IconData icono,
    Color color,
  ) async {
    if (_cargando || _procesando) return;

    final productosVista = _filtrarProductos(tipo);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.84,
          decoration: const BoxDecoration(
            color: Color(0xFF111F31),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(26),
            ),
            border: Border(
              top: BorderSide(color: Colors.white12),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 12),

                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          icono,
                          color: color,
                          size: 23,
                        ),
                      ),

                      const SizedBox(width: 13),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titulo,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${productosVista.length} productos',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(
                  color: Colors.white.withOpacity(0.08),
                  height: 1,
                ),

                Expanded(
                  child: productosVista.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(25),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 48,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'No hay productos en esta categoría.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 25),
                          itemCount: productosVista.length,
                          itemBuilder: (context, index) {
                            return _tarjetaProducto(
                              productosVista[index],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =====================================================
  // TARJETA DE RESUMEN
  // =====================================================

  Widget _tarjetaResumen({
    required String titulo,
    required String valor,
    required IconData icono,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        splashColor: color.withOpacity(0.12),
        highlightColor: color.withOpacity(0.05),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.055),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: Colors.white.withOpacity(0.11),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icono, color: color, size: 23),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withOpacity(0.35),
                      size: 13,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  valor,
                  style: TextStyle(
                    color: color,
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                const Text(
                  'Ver información',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // ACCESOS A GESTIÓN DE LOTES
  // =====================================================

  Widget _botonGestionLotes({
    required String titulo,
    required String descripcion,
    required IconData icono,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.055),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icono,
                  color: color,
                  size: 25,
                ),
                const SizedBox(height: 11),
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  descripcion,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // INTERFAZ PRINCIPAL
  // =====================================================

  @override
  Widget build(BuildContext context) {
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
          style: TextStyle(fontWeight: FontWeight.w600),
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
              // ENCABEZADO
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

              // BUSCADOR ORIGINAL
              const BuscadorProductos(),

              const SizedBox(height: 18),

              // ACCESOS A LOTES
              Row(
                children: [
                  _botonGestionLotes(
                    titulo: 'Registrar entrada',
                    descripcion: 'Agregar unidades y crear un nuevo lote.',
                    icono: Icons.add_box_outlined,
                    color: AppColors.accent,
                    onTap: _procesando || _cargando
                        ? () {}
                        : _registrarEntrada,
                  ),

                  const SizedBox(width: 12),

                  _botonGestionLotes(
                    titulo: 'Consultar lotes',
                    descripcion: 'Ver cantidades y fechas de vencimiento.',
                    icono: Icons.inventory_outlined,
                    color: const Color(0xFF69B9FF),
                    onTap: _procesando
                        ? () {}
                        : _consultarLotes,
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // CARGA Y ERRORES
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
                        ),
                        onPressed: _cargarProductos,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              else ...[
                // RESUMEN DEL INVENTARIO
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.05,
                  children: [
                    _tarjetaResumen(
                      titulo: 'Productos',
                      valor: '${_productos.length}',
                      icono: Icons.inventory_2_outlined,
                      color: const Color(0xFF2E8BFF),
                      onTap: () => _abrirDetalle(
                        'productos',
                        'Todos los productos',
                        Icons.inventory_2_outlined,
                        const Color(0xFF2E8BFF),
                      ),
                    ),

                    _tarjetaResumen(
                      titulo: 'Unidades',
                      valor: '$_unidades',
                      icono: Icons.warehouse_outlined,
                      color: Colors.white,
                      onTap: () => _abrirDetalle(
                        'unidades',
                        'Unidades disponibles',
                        Icons.warehouse_outlined,
                        Colors.white,
                      ),
                    ),

                    _tarjetaResumen(
                      titulo: 'Stock bajo',
                      valor: '$_stockBajo',
                      icono: Icons.warning_amber_rounded,
                      color: const Color(0xFFFFC400),
                      onTap: () => _abrirDetalle(
                        'bajo',
                        'Productos con stock bajo',
                        Icons.warning_amber_rounded,
                        const Color(0xFFFFC400),
                      ),
                    ),

                    _tarjetaResumen(
                      titulo: 'Agotados',
                      valor: '$_agotados',
                      icono: Icons.remove_shopping_cart_outlined,
                      color: const Color(0xFFFF6675),
                      onTap: () => _abrirDetalle(
                        'agotados',
                        'Productos agotados',
                        Icons.remove_shopping_cart_outlined,
                        const Color(0xFFFF6675),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
