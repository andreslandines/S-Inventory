
import 'package:flutter/material.dart';
import 'package:s_inventory/services/producto_service.dart';
import 'package:s_inventory/services/vencimiento_service.dart';

class RegistrarEntradaPage extends StatefulWidget {
  // Producto que se preselecciona al abrir la pantalla (opcional).
  final Map<String, dynamic>? productoInicial;

  const RegistrarEntradaPage({
    super.key,
    this.productoInicial,
  });

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
      _mostrarMensaje('El producto seleccionado no tiene un ID válido.',
          error: true);
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
      final numeroLote = lote is Map
          ? lote['numero_lote']?.toString()
          : null;

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

      _mostrarMensaje(
        'No se pudo registrar la entrada: $e',
        error: true,
      );
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
          ? const Center(
              child: CircularProgressIndicator(color: amarillo),
            )
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
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                          ),
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
                      DropdownButtonFormField<Map<String, dynamic>>(
                        value: _productoSeleccionado,
                        isExpanded: true,
                        dropdownColor: tarjeta,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoracion(
                          'Selecciona un producto',
                          icono: const Icon(
                            Icons.shopping_bag_outlined,
                            color: amarillo,
                          ),
                        ),
                        items: _productos.map((producto) {
                          final nombre =
                              producto['nombre']?.toString() ?? 'Sin nombre';
                          final stock =
                              producto['stock']?.toString() ?? '0';

                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: producto,
                            child: Text(
                              '$nombre · Stock: $stock',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: _guardando
                            ? null
                            : (producto) {
                                setState(() {
                                  _productoSeleccionado = producto;
                                });
                              },
                      ),

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
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
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
