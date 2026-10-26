import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/services/ventas_servicios.dart';

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

  String _etiqueta(String texto) {
    return texto
        .replaceAll('_', ' ')
        .split(' ')
        .where((parte) => parte.isNotEmpty)
        .map((parte) => parte[0].toUpperCase() + parte.substring(1))
        .join(' ');
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
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.fondoComponentes,
          insetPadding: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: Colors.white.withOpacity(0.10),
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.accent,
                        size: 29,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Recibo de venta #$id',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24),
                  Flexible(
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: VentaService().obtenerVentaPorId(id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(35),
                            child: CircularProgressIndicator(
                              color: AppColors.accent,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Color(0xFFFF7777),
                                  size: 36,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No se pudo cargar el recibo.',
                                  style: TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${snapshot.error}',
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        final datos = snapshot.data ?? venta;

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _campo('Número de venta', '#$id'),
                              ..._construirCampos(datos),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pop(dialogContext),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Cerrar recibo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        side: BorderSide(
                          color: AppColors.accent.withOpacity(0.5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _construirCampos(
    Map<String, dynamic> datos, {
    int nivel = 0,
  }) {
    final widgets = <Widget>[];

    for (final entrada in datos.entries) {
      final clave = entrada.key;
      final valor = entrada.value;

      if (clave == 'id_venta' || valor == null) continue;

      if (valor is Map) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              _etiqueta(clave),
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        );

        widgets.addAll(
          _construirCampos(
            Map<String, dynamic>.from(valor),
            nivel: nivel + 1,
          ),
        );
      } else if (valor is List) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 8),
            child: Text(
              _etiqueta(clave),
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        );

        if (valor.isEmpty) {
          widgets.add(_campo('Información', 'Sin registros'));
        } else {
          for (var i = 0; i < valor.length; i++) {
            final elemento = valor[i];

            widgets.add(
              _campo(
                'Elemento ${i + 1}',
                elemento is Map || elemento is List
                    ? ''
                    : elemento.toString(),
              ),
            );

            if (elemento is Map) {
              widgets.addAll(
                _construirCampos(
                  Map<String, dynamic>.from(elemento),
                  nivel: nivel + 1,
                ),
              );
            } else if (elemento is List) {
              widgets.addAll(
                _construirCampos(
                  {'Detalle': elemento},
                  nivel: nivel + 1,
                ),
              );
            }
          }
        }
      } else {
        widgets.add(
          _campo(_etiqueta(clave), valor.toString()),
        );
      }
    }

    return widgets;
  }

  Widget _campo(String etiqueta, String valor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
          if (valor.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              valor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recientes = [...ventas];

    recientes.sort((a, b) {
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
            'Ventas recientes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          if (lista.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Todavía no hay ventas registradas',
                  style: TextStyle(color: Colors.white60),
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

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _mostrarRecibo(context, venta),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.fondoComponentes.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.receipt_long_rounded,
                          color: AppColors.accent,
                          size: 26,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Venta #$id',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _fecha(venta['fecha']),
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            formatearDinero(total),
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white60,
                        ),
                      ],
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
