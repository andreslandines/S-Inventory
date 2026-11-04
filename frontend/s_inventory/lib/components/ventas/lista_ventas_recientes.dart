
import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/components/ventas/recibo_venta_dialog.dart';

enum PeriodoVentas {
  estaSemana,
  semanaPasada,
  ultimoMes,
}

class ListaVentasRecientes extends StatefulWidget {
  final List<Map<String, dynamic>> ventas;
  final String Function(num) formatearDinero;

  const ListaVentasRecientes({
    super.key,
    required this.ventas,
    required this.formatearDinero,
  });

  @override
  State<ListaVentasRecientes> createState() =>
      _ListaVentasRecientesState();
}

class _ListaVentasRecientesState extends State<ListaVentasRecientes> {
  PeriodoVentas _periodoSeleccionado = PeriodoVentas.semanaPasada;

  DateTime? _obtenerFecha(dynamic valor) {
    final fecha = DateTime.tryParse(valor?.toString() ?? '');
    return fecha?.toLocal();
  }

  String _fecha(dynamic valor) {
    final fecha = _obtenerFecha(valor);
    if (fecha == null) return 'Fecha no disponible';

    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  DateTime _inicioSemana(DateTime fecha) {
    final dia = DateTime(fecha.year, fecha.month, fecha.day);
    return dia.subtract(Duration(days: dia.weekday - 1));
  }

  void _mostrarRecibo(
    BuildContext context,
    Map<String, dynamic> venta,
  ) {
    final id = venta['id_venta']?.toString();

    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La venta no tiene un identificador válido.'),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (_) => ReciboVentaDialog(
        id: id,
        venta: venta,
      ),
    );
  }

  List<Map<String, dynamic>> _ordenar(
    List<Map<String, dynamic>> lista,
  ) {
    final resultado = [...lista];

    resultado.sort((a, b) {
      final fechaA = _obtenerFecha(a['fecha']) ?? DateTime(2000);
      final fechaB = _obtenerFecha(b['fecha']) ?? DateTime(2000);

      return fechaB.compareTo(fechaA);
    });

    return resultado;
  }

  Widget _tarjetaVenta(
    BuildContext context,
    Map<String, dynamic> venta,
  ) {
    final id = venta['id_venta']?.toString() ?? '—';

    final total = double.tryParse(
          venta['total']?.toString() ?? '0',
        ) ??
        0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _mostrarRecibo(context, venta),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: AppColors.fondoComponentes.withOpacity(0.55),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.accent,
                  size: 22,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Venta #$id',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _fecha(venta['fecha']),
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.formatearDinero(total),
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.accent,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mensaje(String texto) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _tituloSeccion(String titulo, IconData icono) {
    return Row(
      children: [
        Icon(icono, color: AppColors.accent, size: 18),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _opcionPeriodo(
    String titulo,
    IconData icono,
    PeriodoVentas periodo,
  ) {
    final seleccionado = _periodoSeleccionado == periodo;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _periodoSeleccionado = periodo;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 5,
          ),
          decoration: BoxDecoration(
            color: seleccionado
                ? AppColors.secondary.withOpacity(0.20)
                : AppColors.fondoComponentes,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: seleccionado
                  ? AppColors.accent
                  : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icono,
                size: 19,
                color: seleccionado
                    ? AppColors.accent
                    : Colors.white60,
              ),
              const SizedBox(height: 5),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: seleccionado
                      ? Colors.white
                      : Colors.white70,
                  fontSize: 10,
                  fontWeight: seleccionado
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ahora = DateTime.now();
    final inicioSemana = _inicioSemana(ahora);
    final finSemana = inicioSemana.add(const Duration(days: 7));

    final inicioSemanaPasada =
        inicioSemana.subtract(const Duration(days: 7));

    final inicioUltimos30Dias =
        DateTime(ahora.year, ahora.month, ahora.day)
            .subtract(const Duration(days: 29));

    final ventasOrdenadas = _ordenar(widget.ventas);

    // Ventas de la semana actual.
    final ventasSemana = ventasOrdenadas.where((venta) {
      final fecha = _obtenerFecha(venta['fecha']);

      return fecha != null &&
          !fecha.isBefore(inicioSemana) &&
          fecha.isBefore(finSemana);
    }).take(8).toList();

    // Ventas anteriores según el periodo seleccionado.
    final ventasAnteriores = ventasOrdenadas.where((venta) {
      final fecha = _obtenerFecha(venta['fecha']);

      if (fecha == null) return false;

      switch (_periodoSeleccionado) {
        case PeriodoVentas.estaSemana:
          return !fecha.isBefore(inicioSemana) &&
              fecha.isBefore(finSemana);

        case PeriodoVentas.semanaPasada:
          return !fecha.isBefore(inicioSemanaPasada) &&
              fecha.isBefore(inicioSemana);

        case PeriodoVentas.ultimoMes:
          return !fecha.isBefore(inicioUltimos30Dias) &&
              fecha.isBefore(ahora.add(const Duration(seconds: 1)));
      }
    }).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.09),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // VENTAS DE ESTA SEMANA
          _tituloSeccion(
            'Ventas recientes',
            Icons.calendar_view_week_rounded,
          ),
          const SizedBox(height: 5),
          Text(
            '${_fecha(inicioSemana.toIso8601String())} - '
            '${_fecha(finSemana.subtract(const Duration(days: 1)).toIso8601String())}',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 12),

          if (ventasSemana.isEmpty)
            _mensaje('Todavía no hay ventas esta semana.')
          else
            ...ventasSemana.map(
              (venta) => _tarjetaVenta(context, venta),
            ),

          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.10)),
          const SizedBox(height: 12),

          // HISTORIAL
          _tituloSeccion(
            'Consultar ventas anteriores',
            Icons.history_rounded,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _opcionPeriodo(
                'Esta semana',
                Icons.calendar_today_rounded,
                PeriodoVentas.estaSemana,
              ),
              const SizedBox(width: 7),
              _opcionPeriodo(
                'Semana pasada',
                Icons.calendar_view_week_rounded,
                PeriodoVentas.semanaPasada,
              ),
              const SizedBox(width: 7),
              _opcionPeriodo(
                'Último mes',
                Icons.calendar_month_rounded,
                PeriodoVentas.ultimoMes,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            '${ventasAnteriores.length} venta(s) encontradas',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),

          if (ventasAnteriores.isEmpty)
            _mensaje(
              'No hay ventas registradas en este periodo.',
            )
          else
            ...ventasAnteriores.map(
              (venta) => _tarjetaVenta(context, venta),
            ),
        ],
      ),
    );
  }
}
