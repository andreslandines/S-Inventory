import 'package:flutter/material.dart';
import 'package:s_inventory/services/producto_service.dart';
import 'package:s_inventory/services/vencimiento_service.dart';

class RegistrarEntradaPage extends StatefulWidget {
  // Producto que se preselecciona al abrir la pantalla (opcional).
  final Map<String, dynamic>? productoInicial;

  const RegistrarEntradaPage({super.key, this.productoInicial});

  @override
  State<RegistrarEntradaPage> createState() => _RegistrarEntradaPageState();
}

class _RegistrarEntradaPageState extends State<RegistrarEntradaPage> {
  final ProductoService _productoService = ProductoService();
  final VencimientoService _vencimientoService = VencimientoService();

  final TextEditingController _cantidadController = TextEditingController();

  List<Map<String, dynamic>> _productos = [];
  Map<String, dynamic>? _productoSeleccionado;

  DateTime? _fechaVencimiento;

  bool _cargandoProductos = true;
  bool _guardando = false;

  static const Color fondo = Color(0xFF111827);
  static const Color tarjeta = Color(0xFF1F2937);
  static const Color amarillo = Color(0xFFFFC400);

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _cargarProductos() async {
    try {
      final productos = await _productoService.obtenerProductos();

      if (!mounted) return;

      setState(() {
        _productos = productos;
        _productoSeleccionado = _buscarProductoInicial(productos);
        _cargandoProductos = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargandoProductos = false;
      });

      _mostrarMensaje('No se pudieron cargar los productos: $e', error: true);
    }
  }

  // Busca en la lista el producto que se quiso preseleccionar.
  Map<String, dynamic>? _buscarProductoInicial(
    List<Map<String, dynamic>> productos,
  ) {
    final inicial = widget.productoInicial;

    if (inicial == null) return null;

    final id = inicial['id_productos']?.toString();

    if (id == null) return null;

    for (final producto in productos) {
      if (producto['id_productos']?.toString() == id) {
        return producto;
      }
    }

    return null;
  }

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();

    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento ?? hoy,
      firstDate: DateTime(hoy.year, hoy.month, hoy.day),
      lastDate: DateTime(hoy.year + 20),
      helpText: 'Seleccionar fecha de vencimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: amarillo,
              surface: tarjeta,
              onPrimary: fondo,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fecha != null) {
      setState(() {
        _fechaVencimiento = fecha;
      });
    }
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }

  String _fechaParaBackend(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '${fecha.year}-$mes-$dia';
  }

  void _mostrarMensaje(String mensaje, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: error ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _registrarEntrada() async {
    if (_productoSeleccionado == null) {
      _mostrarMensaje('Selecciona un producto.', error: true);
      return;
    }

    final cantidad = int.tryParse(_cantidadController.text.trim());

    if (cantidad == null || cantidad <= 0) {
      _mostrarMensaje(
        'Ingresa una cantidad válida mayor que cero.',
        error: true,
      );
      return;
    }

    final idProducto = _productoSeleccionado!['id_productos'];

    if (idProducto == null) {
      _mostrarMensaje(
        'El producto seleccionado no tiene un ID válido.',
        error: true,
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final respuesta = await _vencimientoService.registrarEntrada(
        idProducto: idProducto.toString(),
        cantidad: cantidad,
        fechaVencimiento: _fechaVencimiento == null
            ? null
            : _fechaParaBackend(_fechaVencimiento!),
      );

      if (!mounted) return;

      setState(() {
        _guardando = false;
      });

      final lote = respuesta['lote'];
      final numeroLote = lote is Map ? lote['numero_lote']?.toString() : null;

      _mostrarMensaje(
        numeroLote != null
            ? 'Entrada registrada correctamente. Lote #$numeroLote.'
            : 'Entrada registrada correctamente.',
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _guardando = false;
      });

      _mostrarMensaje('No se pudo registrar la entrada: $e', error: true);
    }
  }

  Widget _campoTitulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  InputDecoration _decoracion(String texto, {Widget? icono}) {
    return InputDecoration(
      hintText: texto,
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: icono,
      filled: true,
      fillColor: tarjeta,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: amarillo),
      ),
    );
  }

  // Imagen del producto (se reutiliza en la card y en el selector).
  Widget _imagenProducto(Map<String, dynamic> producto, {double size = 64}) {
    final imagen = producto['imagen']?.toString().trim() ?? '';

    if (imagen.isEmpty) {
      return _imagenVacia(size);
    }

    return Image.network(
      imagen,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _imagenVacia(size),
    );
  }

  Widget _imagenVacia(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: amarillo.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        color: amarillo,
        size: size * 0.5,
      ),
    );
  }

  // Card con los datos del producto que se seleccionó en el dropdown.
  Widget _cardProductoSeleccionado(Map<String, dynamic> producto) {
    final nombre = producto['nombre']?.toString() ?? 'Sin nombre';
    final categoria = producto['categoria']?.toString().trim() ?? '';
    final descripcion = producto['descripcion']?.toString().trim() ?? '';
    final stock = producto['stock']?.toString() ?? '0';
    final precio = producto['precio']?.toString() ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tarjeta,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: amarillo.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _imagenProducto(producto),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (categoria.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    categoria,
                    style: const TextStyle(color: amarillo, fontSize: 12),
                  ),
                ],
                if (descripcion.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _chipInfo(
                      icono: Icons.inventory_2_outlined,
                      texto: 'Stock: $stock',
                    ),
                    if (precio.isNotEmpty)
                      _chipInfo(icono: Icons.attach_money, texto: '\$$precio'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipInfo({required IconData icono, required String texto}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: amarillo),
          const SizedBox(width: 5),
          Text(
            texto,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Selector de productos con buscador y tarjetas.
  Future<void> _abrirSelectorProductos() async {
    if (_guardando) return;

    final busqueda = TextEditingController();

    final elegido = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: tarjeta,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final consulta = busqueda.text.trim().toLowerCase();

            final filtrados = _productos.where((producto) {
              if (consulta.isEmpty) return true;

              final nombre = producto['nombre']?.toString().toLowerCase() ?? '';
              final categoria =
                  producto['categoria']?.toString().toLowerCase() ?? '';
              final codigo =
                  producto['codigo_barras']?.toString().toLowerCase() ?? '';

              return nombre.contains(consulta) ||
                  categoria.contains(consulta) ||
                  codigo.contains(consulta);
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.72,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Seleccionar producto',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: busqueda,
                      onChanged: (_) => setSheetState(() {}),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre, categoría o código',
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(Icons.search, color: amarillo),
                        filled: true,
                        fillColor: fondo,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: amarillo),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filtrados.isEmpty
                          ? const Center(
                              child: Text(
                                'No se encontraron productos.',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: filtrados.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (_, index) {
                                final producto = filtrados[index];
                                final esActual =
                                    _productoSeleccionado?['id_productos']
                                        ?.toString() ==
                                    producto['id_productos']?.toString();
                                final nombre =
                                    producto['nombre']?.toString() ??
                                    'Sin nombre';
                                final categoria =
                                    producto['categoria']?.toString().trim() ??
                                    '';
                                final stock =
                                    producto['stock']?.toString() ?? '0';
                                final precio =
                                    producto['precio']?.toString() ?? '';

                                return ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                      color: esActual
                                          ? amarillo
                                          : Colors.white12,
                                    ),
                                  ),
                                  tileColor: esActual
                                      ? amarillo.withValues(alpha: 0.08)
                                      : fondo,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: _imagenProducto(producto, size: 46),
                                  ),
                                  title: Text(
                                    nombre,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    categoria.isNotEmpty
                                        ? '$categoria · Stock: $stock'
                                        : 'Stock: $stock',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (precio.isNotEmpty)
                                        Text(
                                          '\$$precio',
                                          style: const TextStyle(
                                            color: amarillo,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      if (esActual)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 8),
                                          child: Icon(
                                            Icons.check_circle,
                                            color: amarillo,
                                            size: 18,
                                          ),
                                        ),
                                    ],
                                  ),
                                  onTap: () =>
                                      Navigator.pop(sheetContext, producto),
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
      },
    );

    busqueda.dispose();

    if (elegido != null && mounted) {
      setState(() {
        _productoSeleccionado = elegido;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        backgroundColor: fondo,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Registrar entrada',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _cargandoProductos
          ? const Center(child: CircularProgressIndicator(color: amarillo))
          : _productos.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No hay productos registrados para agregar existencias.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: tarjeta,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color: amarillo,
                          size: 30,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Registra nuevas unidades. Cada entrada se almacenará como un lote independiente.',
                            style: TextStyle(
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  _campoTitulo('Producto'),
                  InkWell(
                    onTap: _guardando ? null : _abrirSelectorProductos,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: tarjeta,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            color: amarillo,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _productoSeleccionado == null
                                      ? 'Selecciona un producto'
                                      : _productoSeleccionado!['nombre']
                                                ?.toString() ??
                                            'Sin nombre',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: _productoSeleccionado == null
                                        ? Colors.white38
                                        : Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                if (_productoSeleccionado != null) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    'Stock: ${_productoSeleccionado!['stock']?.toString() ?? '0'} · Toca para cambiar',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: amarillo,
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_productoSeleccionado != null)
                    _cardProductoSeleccionado(_productoSeleccionado!),

                  const SizedBox(height: 22),

                  _campoTitulo('Cantidad que ingresa'),
                  TextField(
                    controller: _cantidadController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _decoracion(
                      'Ejemplo: 20',
                      icono: const Icon(
                        Icons.add_box_outlined,
                        color: amarillo,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  _campoTitulo('Fecha de vencimiento'),
                  InkWell(
                    onTap: _guardando ? null : _seleccionarFecha,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 17,
                      ),
                      decoration: BoxDecoration(
                        color: tarjeta,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            color: amarillo,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _fechaVencimiento == null
                                  ? 'Sin fecha de vencimiento'
                                  : _formatearFecha(_fechaVencimiento!),
                              style: TextStyle(
                                color: _fechaVencimiento == null
                                    ? Colors.white54
                                    : Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (_fechaVencimiento != null)
                            IconButton(
                              tooltip: 'Quitar fecha',
                              onPressed: _guardando
                                  ? null
                                  : () {
                                      setState(() {
                                        _fechaVencimiento = null;
                                      });
                                    },
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white54,
                              ),
                            )
                          else
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white54,
                              size: 16,
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    'La fecha es opcional. Si no la conoces, puedes registrar el lote sin fecha.',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _guardando ? null : _registrarEntrada,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: amarillo,
                        foregroundColor: fondo,
                        disabledBackgroundColor: amarillo.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: _guardando
                          ? const SizedBox(
                              width: 19,
                              height: 19,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: fondo,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        _guardando ? 'Registrando...' : 'Registrar entrada',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
