import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/core/estilostexto.dart';

class ResumenInventario extends StatelessWidget {
  final int totalProductos;
  final int unidades;
  final int stockBajo;
  final int agotados;

  const ResumenInventario({
    super.key,
    required this.totalProductos,
    required this.unidades,
    required this.stockBajo,
    required this.agotados,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        _tarjeta(
          'Productos',
          totalProductos,
          Icons.inventory_2_outlined,
          AppColors.secondary,
        ),
        _tarjeta(
          'Unidades',
          unidades,
          Icons.warehouse_outlined,
          Colors.white,
        ),
        _tarjeta(
          'Stock bajo',
          stockBajo,
          Icons.warning_amber_rounded,
          AppColors.accent,
        ),
        _tarjeta(
          'Agotados',
          agotados,
          Icons.remove_shopping_cart_outlined,
          const Color(0xFFFF7777),
        ),
      ],
    );
  }

  Widget _tarjeta(
    String titulo,
    int valor,
    IconData icono,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFA4A1A1).withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white12,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final ancho = constraints.maxWidth;
          final alto = constraints.maxHeight;

          final double tamanoIcono =
              (ancho * 0.17).clamp(20.0, 32.0).toDouble();

          final double tamanoNumero =
              (ancho * 0.20).clamp(22.0, 34.0).toDouble();

          final double tamanoTitulo =
              (ancho * 0.10).clamp(12.0, 16.0).toDouble();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icono,
                color: color,
                size: tamanoIcono,
              ),
              const Spacer(),
              Text(
                titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Estilotextos.textoPequeno.copyWith(
                  color: Colors.white70,
                  fontSize: tamanoTitulo,
                ),
              ),
              SizedBox(height: alto < 100 ? 2 : 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '$valor',
                  style: TextStyle(
                    color: color,
                    fontSize: tamanoNumero,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}