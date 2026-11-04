
import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/components/ventas/recibo_venta_dialog.dart';

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
  final TextEditingController _busquedaController =
      TextEditingController();

  String _busqueda = '';

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
      final fechaA =
          _obtenerFecha(a['fecha']) ?? DateTime(2000);
      final fechaB =
          _obtenerFecha(b['fecha']) ?? DateTime(2000);

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

  @override
  Widget build(BuildContext context) {
    final ahora = DateTime.now();
    final inicio = _inicioSemana(ahora);
    final fin = inicio.add(const Duration(days: 7));

    final ventasOrdenadas = _ordenar(widget.ventas);

    // Ventas comprendidas entre lunes y domingo.
    final ventasSemana = ventasOrdenadas.where((venta) {
      final fecha = _obtenerFecha(venta['fecha']);

      return fecha != null &&
          !fecha.isBefore(inicio) &&
          fecha.isBefore(fin);
    }).take(8).toList();

    // Ventas anteriores al inicio de la semana actual.
    final historial = ventasOrdenadas.where((venta) {
      final fecha = _obtenerFecha(venta['fecha']);
      return fecha != null && fecha.isBefore(inicio);
    }).toList();

    // Búsqueda por número de venta o fecha.
    final consulta = _busqueda.trim().toLowerCase();

    final resultadosHistorial = historial.where((venta) {
      if (consulta.isEmpty) return false;

      final id = venta['id_venta']?.toString().toLowerCase() ?? '';
      final fecha = _fecha(venta['fecha']).toLowerCase();
      final fechaOriginal =
          venta['fecha']?.toString().toLowerCase() ?? '';

      return id.contains(consulta) ||
          fecha.contains(consulta) ||
          fechaOriginal.contains(consulta);
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
          // VENTAS DE LA SEMANA
          _tituloSeccion(
            'Ventas de esta semana',
            Icons.calendar_view_week_rounded,
          ),
          const SizedBox(height: 5),
          Text(
            '${_fecha(inicio.toIso8601String())} - '
            '${_fecha(fin.subtract(const Duration(days: 1)).toIso8601String())}',
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
            'Historial de ventas',
            Icons.history_rounded,
          ),
          const SizedBox(height: 10),

          TextField(
            controller: _busquedaController,
            onChanged: (valor) {
              setState(() => _busqueda = valor);
            },
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            decoration: InputDecoration(
              hintText: 'Buscar por número o fecha...',
              hintStyle: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
              suffixIcon: _busqueda.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _busquedaController.clear();
                        setState(() => _busqueda = '');
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white60,
                        size: 18,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.fondoComponentes,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.secondary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          if (historial.isEmpty)
            _mensaje('Todavía no hay ventas de semanas anteriores.')
          else if (consulta.isEmpty)
            _mensaje(
              'Escribe un número de venta o una fecha para '
              'consultar las ventas anteriores.',
            )
          else if (resultadosHistorial.isEmpty)
            _mensaje('No se encontraron ventas con esa búsqueda.')
          else ...[
            Text(
              '${resultadosHistorial.length} venta(s) encontrada(s)',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 8),
            ...resultadosHistorial.map(
              (venta) => _tarjetaVenta(context, venta),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }
}
