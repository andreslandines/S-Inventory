import 'package:flutter/material.dart';
import 'package:s_inventory/pages/detalle_producto_page.dart';
import 'package:s_inventory/services/producto_service.dart';
import 'package:s_inventory/services/vencimiento_service.dart';

class LotesPage extends StatefulWidget {
  const LotesPage({super.key});

  @override
  State<LotesPage> createState() => _LotesPageState();
}

class _LotesPageState extends State<LotesPage> {
  final VencimientoService _service = VencimientoService();
  final ProductoService _productoService = ProductoService();
  final TextEditingController _busquedaController = TextEditingController();

  List<Map<String, dynamic>> _lotes = [];
  bool _cargando = true;
  String _filtro = 'Todos';
  String _busqueda = '';
  String? _error;

  static const Color fondo = Color(0xFF111827);
  static const Color tarjeta = Color(0xFF1F2937);
  static const Color amarillo = Color(0xFFFFC400);

  @override
  void initState() {
    super.initState();
    _cargarLotes();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
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

  Future<void> _cargarLotes() async {
    if (!mounted) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resultado = await _service.obtenerLotes();

      if (!mounted) return;

      setState(() {
        _lotes = resultado;
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

  // Abre el detalle del producto asociado al lote. La relación del lote no
  // trae precio, descripción ni código, por eso se completa con elcatálogo.
  Future<void> _abrirDetalleProducto(Map<String, dynamic> lote) async {
    final relacion = _obtenerProducto(lote);
    final id = relacion['id_productos']?.toString();

    if (id == null || id.isEmpty) {
      _mensaje(
        'No se puede abrir el producto de este lote.',
      );
      return;
    }

    Map<String, dynamic> producto = relacion;

    if (id.isNotEmpty) {
      try {
        final productos = await _productoService.obtenerProductos();

        for (final candidato in productos) {
          if (candidato['id_productos']?.toString() == id) {
            producto = candidato;
            break;
          }
        }
      } catch (_) {
        // Si falla la consulta se muestra la información disponible en el lote.
      }
    }

    if (!mounted) return;

    final huboCambios = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleProductoPage(producto: producto),
      ),
    );

    // Agregar stock desde el detalle crea un lote nuevo: hay que recargar.
    if (huboCambios == true && mounted) {
      await _cargarLotes();
    }
  }

  DateTime? _convertirFecha(dynamic valor) {
    if (valor == null || valor.toString().trim().isEmpty) {
      return null;
    }

    try {
      final partes = valor.toString().split('-');

      if (partes.length != 3) return null;

      final fecha = DateTime.utc(
        int.parse(partes[0]),
        int.parse(partes[1]),
        int.parse(partes[2]),
      );

      if (fecha.year != int.parse(partes[0]) ||
          fecha.month != int.parse(partes[1]) ||
          fecha.day != int.parse(partes[2])) {
        return null;
      }

      return fecha;
    } catch (_) {
      return null;
    }
  }

  DateTime get _hoy {
    final ahora = DateTime.now();

    return DateTime.utc(ahora.year, ahora.month, ahora.day);
  }

  int? _diasRestantes(dynamic fecha) {
    final fechaLote = _convertirFecha(fecha);

    if (fechaLote == null) return null;

    return fechaLote.difference(_hoy).inDays;
  }

  String _formatearFecha(dynamic valor) {
    final fecha = _convertirFecha(valor);

    if (fecha == null) return 'Sin fecha registrada';

    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  Map<String, dynamic> _obtenerProducto(Map<String, dynamic> lote) {
    // Supabase normalmente devuelve la relación como objeto.
    final relacion = lote['productos'];

    if (relacion is Map) {
      return Map<String, dynamic>.from(relacion);
    }

    // También soporta una relación recibida como lista.
    if (relacion is List && relacion.isNotEmpty) {
      final primero = relacion.first;

      if (primero is Map) {
        return Map<String, dynamic>.from(primero);
      }
    }

    // Compatibilidad si el backend utiliza otro alias.
    final productoAlternativo = lote['producto'];

    if (productoAlternativo is Map) {
      return Map<String, dynamic>.from(productoAlternativo);
    }

    if (productoAlternativo is List &&
        productoAlternativo.isNotEmpty &&
        productoAlternativo.first is Map) {
      return Map<String, dynamic>.from(productoAlternativo.first as Map);
    }

    return {};
  }

  // Imagen del producto para la tarjeta del lote.
  Widget _imagenProducto(Map<String, dynamic> producto) {
    final imagen = producto['imagen']?.toString().trim() ?? '';

    if (imagen.isEmpty) {
      return _imagenVacia();
    }

    return Image.network(
      imagen,
      width: 43,
      height: 43,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _imagenVacia(),
    );
  }

  // Marcador cuando el producto no tiene imagen disponible.
  Widget _imagenVacia() {
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color: amarillo.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.inventory_2_outlined, color: amarillo),
    );
  }

  String _estadoLote(Map<String, dynamic> lote) {
    final dias = _diasRestantes(lote['fecha_vencimiento']);

    // Un lote sin cantidad registrada no debe tratarse como agotado.
    final cantidadTexto = lote['cantidad_disponible']?.toString();

    final cantidad = cantidadTexto == null ? null : int.tryParse(cantidadTexto);

    if (cantidad != null && cantidad <= 0) return 'Agotado';
    if (dias == null) return 'Sin fecha';
    if (dias < 0) return 'Vencido';
    if (dias <= 30) return 'Próximo a vencer';

    return 'Vigente';
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Vencido':
        return Colors.redAccent;
      case 'Próximo a vencer':
        return Colors.orangeAccent;
      case 'Vigente':
        return Colors.greenAccent;
      case 'Agotado':
        return Colors.white54;
      default:
        return Colors.blueGrey.shade200;
    }
  }

  List<Map<String, dynamic>> get _lotesFiltrados {
    if (_filtro == 'Todos') return _lotes;

    return _lotes.where((lote) {
      final estado = _estadoLote(lote);

      if (_filtro == 'Vencidos') return estado == 'Vencido';
      if (_filtro == 'Próximos') {
        return estado == 'Próximo a vencer';
      }
      if (_filtro == 'Vigentes') {
        return estado == 'Vigente' || estado == 'Sin fecha';
      }
      if (_filtro == 'Agotados') return estado == 'Agotado';

      return true;
    }).toList();
  }

  // Combina el chip de estado seleccionado con la búsqueda por texto.
  List<Map<String, dynamic>> get _lotesVisibles {
    final base = _lotesFiltrados;
    final texto = _busqueda.trim().toLowerCase();

    if (texto.isEmpty) return base;

    return base.where((lote) {
      final producto = _obtenerProducto(lote);

      return [
        producto['nombre']?.toString(),
        producto['categoria']?.toString(),
        lote['numero_lote']?.toString(),
      ].any((valor) => valor != null && valor.toLowerCase().contains(texto));
    }).toList();
  }

  int _contarEstado(String estado) {
    return _lotes.where((lote) => _estadoLote(lote) == estado).length;
  }

  Widget _resumen(String titulo, int cantidad, Color color, IconData icono) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: tarjeta,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, color: color, size: 21),
            const SizedBox(height: 9),
            Text(
              cantidad.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 21,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaLote(Map<String, dynamic> lote) {
    final producto = _obtenerProducto(lote);

    final nombreProducto =
        producto['nombre']?.toString() ?? 'Producto no disponible';

    final numeroLote = lote['numero_lote']?.toString() ?? 'Sin número';

    final cantidadTexto = lote['cantidad_disponible']?.toString();

    final cantidad = cantidadTexto == null ? null : int.tryParse(cantidadTexto);

    final cantidadInicialTexto = lote['cantidad_inicial']?.toString();

    final cantidadInicial = cantidadInicialTexto == null
        ? null
        : int.tryParse(cantidadInicialTexto);

    final fecha = lote['fecha_vencimiento'];
    final estado = _estadoLote(lote);
    final colorEstado = _colorEstado(estado);
    final dias = _diasRestantes(fecha);

    String textoVencimiento;

    if (fecha == null) {
      textoVencimiento = 'No se registró fecha de vencimiento';
    } else if (dias == null) {
      textoVencimiento = 'Fecha: ${_formatearFecha(fecha)}';
    } else if (dias < 0) {
      textoVencimiento =
          'Venció hace ${dias.abs()} ${dias.abs() == 1 ? 'día' : 'días'}';
    } else if (dias == 0) {
      textoVencimiento = 'Vence hoy';
    } else {
      textoVencimiento = 'Vence en $dias ${dias == 1 ? 'día' : 'días'}';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () => _abrirDetalleProducto(lote),
        child: Container(
          margin: const EdgeInsets.only(bottom: 13),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tarjeta,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _imagenProducto(producto),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombreProducto,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lote #$numeroLote',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorEstado.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      estado,
                      style: TextStyle(
                        color: colorEstado,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              Row(
                children: [
                  Expanded(
                    child: _dato(
                      'Disponibles',
                      cantidad == null ? 'Sin dato' : '$cantidad unidades',
                      Icons.inventory_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _dato(
                      'Cantidad inicial',
                      cantidadInicial == null
                          ? 'Sin dato'
                          : '$cantidadInicial unidades',
                      Icons.add_box_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: Colors.white.withOpacity(0.08)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: amarillo,
                    size: 19,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      _formatearFecha(fecha),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
              if (fecha != null) ...[
                const SizedBox(height: 7),
                Text(
                  textoVencimiento,
                  style: TextStyle(
                    color: colorEstado,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 11),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Ver producto',
                    style: TextStyle(
                      color: amarillo,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 3),
                  Icon(Icons.chevron_right, color: amarillo, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dato(String titulo, String valor, IconData icono) {
    return Row(
      children: [
        Icon(icono, color: Colors.white54, size: 18),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
              const SizedBox(height: 3),
              Text(
                valor,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buscador() {
    return TextField(
      controller: _busquedaController,
      onChanged: (valor) => setState(() => _busqueda = valor),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Buscar por producto, lote o categoría...',
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: const Icon(Icons.search, color: amarillo),
        suffixIcon: _busqueda.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpiar búsqueda',
                onPressed: () {
                  _busquedaController.clear();
                  setState(() => _busqueda = '');
                },
                icon: const Icon(Icons.close, color: Colors.white70),
              ),
        filled: true,
        fillColor: tarjeta,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: amarillo),
        ),
      ),
    );
  }

  Widget _filtros() {
    final filtros = ['Todos', 'Vencidos', 'Próximos', 'Vigentes', 'Agotados'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filtros.map((filtro) {
          final seleccionado = _filtro == filtro;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filtro),
              selected: seleccionado,
              onSelected: (_) {
                setState(() {
                  _filtro = filtro;
                });
              },
              selectedColor: amarillo,
              backgroundColor: tarjeta,
              labelStyle: TextStyle(
                color: seleccionado ? fondo : Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              side: BorderSide.none,
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lotes = _lotesVisibles;
    final hayBusqueda = _busqueda.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        backgroundColor: fondo,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Lotes de inventario',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _cargando ? null : _cargarLotes,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: amarillo))
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 42,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No se pudieron cargar los lotes.',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: _cargarLotes,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Intentar nuevamente'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargarLotes,
              color: amarillo,
              backgroundColor: tarjeta,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(18),
                children: [
                  Row(
                    children: [
                      _resumen(
                        'Total de lotes',
                        _lotes.length,
                        amarillo,
                        Icons.inventory_2_outlined,
                      ),
                      const SizedBox(width: 9),
                      _resumen(
                        'Próximos',
                        _contarEstado('Próximo a vencer'),
                        Colors.orangeAccent,
                        Icons.warning_amber_rounded,
                      ),
                      const SizedBox(width: 9),
                      _resumen(
                        'Vencidos',
                        _contarEstado('Vencido'),
                        Colors.redAccent,
                        Icons.event_busy_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 23),
                  const Text(
                    'Filtrar lotes',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 11),
                  _buscador(),
                  const SizedBox(height: 15),
                  _filtros(),
                  const SizedBox(height: 18),
                  Text(
                    '${lotes.length} ${lotes.length == 1 ? 'lote encontrado' : 'lotes encontrados'}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  if (lotes.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: tarjeta,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.inventory_outlined,
                            color: Colors.white38,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            hayBusqueda
                                ? 'No hay lotes que coincidan con la búsqueda.'
                                : 'No hay lotes para mostrar.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    )
                  else
                    ...lotes.map(_tarjetaLote),
                ],
              ),
            ),
    );
  }
}
