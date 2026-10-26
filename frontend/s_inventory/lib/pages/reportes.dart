import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/services/producto_service.dart';
import 'package:s_inventory/services/ventas_servicios.dart';

import 'package:s_inventory/components/encabezado_reportes.dart';
import 'package:s_inventory/components/lista_ventas_recientes.dart';
import 'package:s_inventory/components/grafico_semanal.dart';
import 'package:s_inventory/components/indicador_reporte.dart';


class Reportes extends StatefulWidget {
  const Reportes({super.key});

  @override
  State<Reportes> createState() => _ReportesState();
}

class _ReportesState extends State<Reportes> {
  final _ventaService = VentaService();
  final _productoService = ProductoService();

  List<Map<String, dynamic>> _ventas = [];
  List<Map<String, dynamic>> _productos = [];

  bool _cargando = true;
  String? _error;

  List<Map<String, dynamic>> get _ventasSemana {
    final hoy = DateTime.now();
    final inicio = DateTime(
      hoy.year,
      hoy.month,
      hoy.day,
    ).subtract(const Duration(days: 6));

    final fin = DateTime(
      hoy.year,
      hoy.month,
      hoy.day,
    ).add(const Duration(days: 1));

    return _ventas.where((venta) {
      final fecha = DateTime.tryParse(
        venta['fecha']?.toString() ?? '',
      );

      return fecha != null &&
          !fecha.isBefore(inicio) &&
          fecha.isBefore(fin);
    }).toList();
  }

  double get _totalSemana {
    return _ventasSemana.fold<double>(
      0,
      (suma, venta) =>
          suma +
          (double.tryParse(
                venta['total']?.toString() ?? '0',
              ) ??
              0),
    );
  }

  int get _stockBajo {
    return _productos.where((producto) {
      final stock = int.tryParse(
            producto['stock']?.toString() ?? '0',
          ) ??
          0;

      return stock <= 5;
    }).length;
  }

  String _dinero(num valor) {
    final entero = valor.round().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < entero.length; i++) {
      buffer.write(entero[i]);

      final restantes = entero.length - i - 1;
      if (restantes > 0 && restantes % 3 == 0) {
        buffer.write('.');
      }
    }

    return '\$ $buffer';
  }

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
        _ventaService.obtenerVentas(),
        _productoService.obtenerProductos(),
      ]);

      if (!mounted) return;

      setState(() {
        _ventas = List<Map<String, dynamic>>.from(datos[0]);
        _productos = List<Map<String, dynamic>>.from(datos[1]);
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'No fue posible cargar los reportes.\n$e';
        _cargando = false;
      });
    }
  }

  Widget _titulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _estadisticas() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.12,
      children: [
        IndicadorReporte(
          titulo: 'Ingresos semanales',
          valor: _dinero(_totalSemana),
          descripcion: 'Últimos 7 días',
          icono: Icons.payments_outlined,
          color: AppColors.accent,
        ),
        IndicadorReporte(
          titulo: 'Ventas semanales',
          valor: '${_ventasSemana.length}',
          descripcion: 'Operaciones realizadas',
          icono: Icons.shopping_cart_outlined,
          color: AppColors.secondary,
        ),
        IndicadorReporte(
          titulo: 'Productos',
          valor: '${_productos.length}',
          descripcion: 'En el inventario',
          icono: Icons.inventory_2_outlined,
          color: const Color(0xFF67D5B5),
        ),
        IndicadorReporte(
          titulo: 'Stock bajo',
          valor: '$_stockBajo',
          descripcion: 'Productos con stock ≤ 5',
          icono: Icons.warning_amber_rounded,
          color: const Color(0xFFFF7777),
        ),
      ],
    );
  }

  Widget _contenido() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        EncabezadoReportes(onActualizar: _cargarDatos),
        const SizedBox(height: 22),
        _titulo('Resumen general'),
        _estadisticas(),
        const SizedBox(height: 22),
        GraficoSemanal(
          ventas: _ventasSemana,
          formatearDinero: _dinero,
        ),
        const SizedBox(height: 22),
        ListaVentasRecientes(
          ventas: _ventas,
          formatearDinero: _dinero,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: _cargando
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                ),
              )
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cloud_off_rounded,
                            color: Color(0xFFFF7777),
                            size: 42,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _cargarDatos,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    color: AppColors.accent,
                    backgroundColor: AppColors.fondoComponentes,
                    onRefresh: _cargarDatos,
                    child: _contenido(),
                  ),
      ),
    );
  }
}