
import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/components/ventas/recibo_venta_dialog.dart';

class ListaVentasRecientes extends StatelessWidget {
  final List<Map<String, dynamic>> ventas;
  final String Function(num) formatearDinero;

  const ListaVentasRecientes({
    super.key,
    required this.ventas,
    required this.formatearDinero,
  });

  String _fecha(dynamic valor) {
    final fecha = DateTime.tryParse(valor?.toString() ?? '');
    if (fecha == null) return 'Fecha no disponible';

    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
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

  @override
  Widget build(BuildContext context) {
    final recientes = [...ventas]
      ..sort((a, b) {
        final fechaA = DateTime.tryParse(
              a['fecha']?.toString() ?? '',
            ) ??
            DateTime(2000);

        final fechaB = DateTime.tryParse(
              b['fecha']?.toString() ?? '',
            ) ??
            DateTime(2000);

        return fechaB.compareTo(fechaA);
      });

    final lista = recientes.take(8).toList();

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
          const Text(
            'Ventas recientes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (lista.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Todavía no hay ventas registradas',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ),
            )
          else
            ...lista.map((venta) {
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
                        color: AppColors.fondoComponentes
                            .withOpacity(0.55),
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
                              mainAxisSize: MainAxisSize.min,
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
                            formatearDinero(total),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
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
            }),
        ],
      ),
    );
  }
}
