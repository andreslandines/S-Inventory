
import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/services/ventas_servicios.dart';

class ReciboVentaDialog extends StatelessWidget {
  final String id;
  final Map<String, dynamic> venta;

  const ReciboVentaDialog({
    super.key,
    required this.id,
    required this.venta,
  });

  String _etiqueta(String texto) {
    return texto
        .replaceAll('_', ' ')
        .split(' ')
        .where((parte) => parte.isNotEmpty)
        .map(
          (parte) =>
              parte[0].toUpperCase() + parte.substring(1),
        )
        .join(' ');
  }

  List<Widget> _construirCampos(Map<String, dynamic> datos) {
    final widgets = <Widget>[];

    for (final entrada in datos.entries) {
      final clave = entrada.key;
      final valor = entrada.value;

      if (clave == 'id_venta' || valor == null) continue;

      if (valor is Map) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 5),
            child: Text(
              _etiqueta(clave),
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );
        widgets.addAll(
          _construirCampos(Map<String, dynamic>.from(valor)),
        );
      } else if (valor is List) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 5),
            child: Text(
              _etiqueta(clave),
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );

        if (valor.isEmpty) {
          widgets.add(_campo('Información', 'Sin registros'));
        }

        for (var i = 0; i < valor.length; i++) {
          final elemento = valor[i];

          if (elemento is Map) {
            widgets.add(_campo('Elemento ${i + 1}', ''));
            widgets.addAll(
              _construirCampos(
                Map<String, dynamic>.from(elemento),
              ),
            );
          } else if (elemento is List) {
            widgets.addAll(
              _construirCampos({'Detalle': elemento}),
            );
          } else {
            widgets.add(
              _campo('Elemento ${i + 1}', elemento.toString()),
            );
          }
        }
      } else {
        widgets.add(_campo(_etiqueta(clave), valor.toString()));
      }
    }

    return widgets;
  }

  Widget _campo(String etiqueta, String valor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
          if (valor.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              valor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.fondo,
      insetPadding: const EdgeInsets.all(18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.white.withOpacity(0.10),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.accent,
                    size: 25,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Recibo de venta #$id',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
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
                        padding: EdgeInsets.all(30),
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Color(0xFFFF7777),
                              size: 34,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'No se pudo cargar el recibo.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                              ),
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
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Cerrar recibo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: BorderSide(
                      color: AppColors.accent.withOpacity(0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
