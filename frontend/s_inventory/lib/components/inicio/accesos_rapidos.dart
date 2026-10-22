import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';

class AccesosRapidos extends StatelessWidget {
  final VoidCallback onVenta;
  final VoidCallback onAgregarProducto;

  const AccesosRapidos({
    super.key,
    required this.onVenta,
    required this.onAgregarProducto,
  });

  @override
  Widget build(BuildContext context) {
    final accesos = [
      _Acceso(
        titulo: 'Registrar venta',
        icono: Icons.point_of_sale_outlined,
        accion: onVenta,
      ),
      _Acceso(
        titulo: 'Agregar producto',
        icono: Icons.add_box_outlined,
        accion: onAgregarProducto,
      ),
    ];

    return Row(
      children: accesos.map((acceso) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: acceso.accion,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 115,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.fondoComponentes,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.07),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        acceso.icono,
                        color: AppColors.accent,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        acceso.titulo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Acceso {
  final String titulo;
  final IconData icono;
  final VoidCallback accion;

  const _Acceso({
    required this.titulo,
    required this.icono,
    required this.accion,
  });
}
