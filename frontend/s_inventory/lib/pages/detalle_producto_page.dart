
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/components/producto/confirmar_eliminar_producto.dart';
import 'package:s_inventory/components/producto/formulario.dart';
import 'package:s_inventory/pages/registrar_entrada_page.dart';
import 'package:s_inventory/services/producto_service.dart';

class DetalleProductoPage extends StatefulWidget {
  final Map<String, dynamic> producto;

  const DetalleProductoPage({
    super.key,
    required this.producto,
  });

  @override
  State<DetalleProductoPage> createState() =>
      _DetalleProductoPageState();
}

class _DetalleProductoPageState extends State<DetalleProductoPage> {
  final ProductoService _service = ProductoService();

  late Map<String, dynamic> _producto;
  bool _procesando = false;
  bool _cambios = false;

  @override
  void initState() {
    super.initState();
    _producto = Map<String, dynamic>.from(widget.producto);
  }

  String _valor(String campo, [String defecto = 'No disponible']) {
    final valor = _producto[campo]?.toString().trim() ?? '';
    return valor.isEmpty ? defecto : valor;
  }

  int get _stock =>
      int.tryParse(_valor('stock', '0')) ?? 0;

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

  Future<void> _editar() async {
    final id = _producto['id_productos']?.toString();

    if (id == null || id.isEmpty) {
      _mensaje('No se encontró el ID del producto.', error: true);
      return;
    }

    // Formulario completo: nombre, descripción, categoría, tipo, precio,
    // código de barras e imagen.
    final datos = await FormularioProducto.mostrar(
      context,
      producto: _producto,
    );

    if (datos == null || !mounted) return;

    setState(() => _procesando = true);

    try {
      final XFile? imagen = datos['imagen'] as XFile?;

      await _service.actualizarProducto(
        id: id,
        nombre: datos['nombre'] as String,
        descripcion: datos['descripcion'] as String,
        precio: datos['precio'] as String,
        categoria: datos['categoria'] as String,
        codigoBarras: datos['codigoBarras'] as String?,
        imagenArchivo: imagen,
      );

      if (!mounted) return;

      final productos = await _service.obtenerProductos();

      final actualizado = productos.firstWhere(
        (p) => p['id_productos']?.toString() == id,
        orElse: () => {
          ..._producto,
          'nombre': datos['nombre'],
          'descripcion': datos['descripcion'],
          'precio': datos['precio'],
          'categoria': datos['categoria'],
          'codigo_barras': datos['codigoBarras'],
        },
      );

      if (!mounted) return;

      setState(() {
        _producto = Map<String, dynamic>.from(actualizado);
        _cambios = true;
      });

      _mensaje('Producto actualizado correctamente.');
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

  // Registrar una entrada (nuevo lote) para aumentar las existencias.
  Future<void> _agregarStock() async {
    if (_procesando) return;

    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrarEntradaPage(
          productoInicial: _producto,
        ),
      ),
    );

    if (resultado != true || !mounted) return;

    try {
      final productos = await _service.obtenerProductos();

      final actualizado = productos.firstWhere(
        (p) =>
            p['id_productos']?.toString() ==
            _producto['id_productos']?.toString(),
        orElse: () => _producto,
      );

      if (!mounted) return;

      setState(() {
        _producto = Map<String, dynamic>.from(actualizado);
        _cambios = true;
      });

      _mensaje('Existencias actualizadas correctamente.');
    } catch (e) {
      if (mounted) {
        _mensaje(
          e.toString().replaceFirst('Exception: ', ''),
          error: true,
        );
      }
    }
  }

  Future<void> _eliminar() async {
    final id = _producto['id_productos']?.toString();
    final nombre = _valor('nombre', 'este producto');

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

      // Devuelve true para que el buscador actualice sus resultados.
      Navigator.of(context).pop(true);
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

  Widget _seccion(String titulo, IconData icono) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icono, color: AppColors.accent, size: 19),
          const SizedBox(width: 9),
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dato(String titulo, String valor, IconData icono) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: Colors.white54, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  valor,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagen() {
    final url = _valor('imagen', '');

    return Container(
      width: double.infinity,
      height: 230,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isEmpty
          ? const Icon(
              Icons.inventory_2_outlined,
              color: Colors.white38,
              size: 65,
            )
          : Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white38,
                  size: 55,
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _valor('nombre', 'Producto');
    final stock = _stock;

    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: AppColors.fondo,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Volver',
          onPressed: () => Navigator.of(context).pop(_cambios),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Detalle del producto',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            _imagen(),

            const SizedBox(height: 20),

            Text(
              nombre,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Icon(
                  stock > 5
                      ? Icons.check_circle_rounded
                      : stock > 0
                          ? Icons.warning_amber_rounded
                          : Icons.error_outline_rounded,
                  color: stock > 5
                      ? const Color(0xFF45C48A)
                      : stock > 0
                          ? Colors.orangeAccent
                          : Colors.redAccent,
                  size: 18,
                ),
                const SizedBox(width: 7),
                Text(
                  stock > 0
                      ? '$stock unidades disponibles'
                      : 'Producto agotado',
                  style: TextStyle(
                    color: stock > 5
                        ? const Color(0xFF45C48A)
                        : stock > 0
                            ? Colors.orangeAccent
                            : Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _seccion('Información general', Icons.info_outline_rounded),

            _dato(
              'Precio',
              '\$${_valor('precio')}',
              Icons.attach_money_rounded,
            ),

            _dato(
              'Categoría',
              _valor('categoria'),
              Icons.category_outlined,
            ),

            _dato(
              'Descripción',
              _valor('descripcion'),
              Icons.description_outlined,
            ),

            _dato(
              'Código de barras',
              _valor('codigo_barras'),
              Icons.qr_code_rounded,
            ),

            _dato(
              'Existencias',
              '$stock unidades',
              Icons.warehouse_outlined,
            ),

            const SizedBox(height: 18),

            _seccion('Acciones', Icons.settings_outlined),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _procesando ? null : _agregarStock,
                icon: const Icon(Icons.add_box_outlined),
                label: const Text(
                  'Agregar stock',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.fondo,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _procesando ? null : _editar,
                icon: const Icon(Icons.edit_rounded),
                label: const Text(
                  'Editar producto',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side: BorderSide(
                    color: AppColors.accent.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _procesando ? null : _eliminar,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text(
                  'Eliminar producto',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF7777),
                  side: const BorderSide(
                    color: Color(0x66FF7777),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            if (_procesando) ...[
              const SizedBox(height: 20),
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
