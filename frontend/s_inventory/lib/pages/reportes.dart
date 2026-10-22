
import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/services/producto_service.dart';
import 'package:s_inventory/services/ventas_servicios.dart';

class Reportes extends StatefulWidget {
  const Reportes({super.key});

  @override
  State<Reportes> createState() => _ReportesState();
}

class _ReportesState extends State<Reportes> {
  final _ventasService = VentaService();
  final _productosService = ProductoService();

  List<Map<String, dynamic>> _ventas = [];
  List<Map<String, dynamic>> _productos = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final datos = await Future.wait([
        _ventasService.obtenerVentas(),
        _productosService.obtenerProductos(),
      ]);

      if (!mounted) return;

      setState(() {
        _ventas = datos[0];
        _productos = datos[1];
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

  DateTime? _fecha(Map<String, dynamic> venta) =>
      DateTime.tryParse('${venta['fecha'] ?? ''}')?.toLocal();

  List<Map<String, dynamic>> get _ventasSemana {
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day)
        .subtract(const Duration(days: 6));

    return _ventas.where((venta) {
      final fecha = _fecha(venta);
      return fecha != null &&
          !fecha.isBefore(inicio) &&
          !fecha.isAfter(hoy);
    }).toList();
  }

  double get _totalSemana => _ventasSemana.fold<double>(
        0,
        (suma, venta) =>
            suma + (double.tryParse('${venta['total']}') ?? 0),
      );

  int get _stockBajo => _productos.where((p) {
        return (int.tryParse('${p['stock']}') ?? 0) <= 5;
      }).length;

  String _dinero(num valor) => '\$${valor.toStringAsFixed(0)}';

  String _dia(DateTime fecha) {
    const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return dias[fecha.weekday - 1];
  }

  String _fechaTexto(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year} · $hora:$minuto';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.fondo,
      child: RefreshIndicator(
        onRefresh: _cargarDatos,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Reportes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Conoce el movimiento de tu negocio.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            if (_cargando)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              _estadoError()
            else ...[
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.35,
                children: [
                  _indicador(
                    'Ventas de 7 días',
                    _dinero(_totalSemana),
                    Icons.payments_outlined,
                    AppColors.secondary,
                  ),
                  _indicador(
                    'Número de ventas',
                    '${_ventasSemana.length}',
                    Icons.receipt_long_outlined,
                    AppColors.accent,
                  ),
                  _indicador(
                    'Productos',
                    '${_productos.length}',
                    Icons.inventory_2_outlined,
                    const Color(0xFF4CAF87),
                  ),
                  _indicador(
                    'Stock bajo',
                    '$_stockBajo',
                    Icons.warning_amber_rounded,
                    Colors.orangeAccent,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Ventas de los últimos 7 días',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _graficoSemanal(),
              const SizedBox(height: 24),
              const Text(
                'Ventas recientes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (_ventas.isEmpty)
                _mensaje('Todavía no hay ventas registradas.')
              else
                ..._ventas.take(8).map(_filaVenta),
              const SizedBox(height: 16),
              const Text(
                'Consideramos stock bajo cuando hay 5 unidades o menos.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _indicador(
    String titulo,
    String valor,
    IconData icono,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.fondoComponentes,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icono, color: color, size: 23),
          Text(
            valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            titulo,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _graficoSemanal() {
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day)
        .subtract(const Duration(days: 6));

    final valores = List<double>.generate(7, (i) {
      final dia = inicio.add(Duration(days: i));

      return _ventasSemana.where((venta) {
        final fecha = _fecha(venta);
        return fecha != null &&
            fecha.year == dia.year &&
            fecha.month == dia.month &&
            fecha.day == dia.day;
      }).fold<double>(
        0,
        (suma, venta) =>
            suma + (double.tryParse('${venta['total']}') ?? 0),
      );
    });

    final maximo = valores.fold<double>(
      0,
      (a, b) => a > b ? a : b,
    );

    return Container(
      height: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fondoComponentes,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (i) {
          final dia = inicio.add(Duration(days: i));
          final altura =
              maximo == 0 ? 5.0 : valores[i] / maximo * 85;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: altura,
                        width: 18,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _dia(dia),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _filaVenta(Map<String, dynamic> venta) {
    final fecha = _fecha(venta);
    final total = double.tryParse('${venta['total']}') ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.receipt_long, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Venta #${venta['id_venta'] ?? '—'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fecha == null
                      ? 'Fecha no disponible'
                      : _fechaTexto(fecha),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _dinero(total),
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _estadoError() {
    return Column(
      children: [
        const Icon(Icons.cloud_off, color: Colors.white54, size: 42),
        const SizedBox(height: 10),
        Text(
          _error!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _cargarDatos,
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
      ],
    );
  }

  Widget _mensaje(String texto) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.fondoComponentes,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }
}
