import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';

class GraficoSemanal extends StatelessWidget {
  final List<Map<String, dynamic>> ventas;
  final String Function(num) formatearDinero;

  const GraficoSemanal({
    super.key,
    required this.ventas,
    required this.formatearDinero,
  });

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final dias = List.generate(
      7,
      (i) => DateTime(
        hoy.year,
        hoy.month,
        hoy.day,
      ).subtract(Duration(days: 6 - i)),
    );

    final ingresos = dias.map((dia) {
      double total = 0;

      for (final venta in ventas) {
        final fecha = DateTime.tryParse(
          venta['fecha']?.toString() ?? '',
        );

        if (fecha != null &&
            fecha.year == dia.year &&
            fecha.month == dia.month &&
            fecha.day == dia.day) {
          total += double.tryParse(
                venta['total']?.toString() ?? '0',
              ) ??
              0;
        }
      }

      return total;
    }).toList();

    final maximo = ingresos.fold<double>(
      0,
      (anterior, actual) =>
          actual > anterior ? actual : anterior,
    );

    const nombres = [
      'L', 'M', 'X', 'J', 'V', 'S', 'D',
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.09),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ventas de los últimos 7 días',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Mayor ingreso diario: ${formatearDinero(maximo)}',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final proporcion = maximo == 0
                    ? 0.0
                    : ingresos[i] / maximo;

                final esHoy = i == 6;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          ingresos[i] > 0
                              ? formatearDinero(ingresos[i])
                              : '',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 9,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 7),
                        Container(
                          height: 90 * proporcion + 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: esHoy
                                  ? [
                                      AppColors.accent,
                                      AppColors.accent.withOpacity(0.45),
                                    ]
                                  : [
                                      AppColors.secondary,
                                      AppColors.primary,
                                    ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          nombres[dias[i].weekday - 1],
                          style: TextStyle(
                            color: esHoy
                                ? AppColors.accent
                                : Colors.white60,
                            fontSize: 12,
                            fontWeight: esHoy
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}