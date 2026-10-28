
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _tarjeta(
                'Productos',
                totalProductos,
                Icons.inventory_2_outlined,
                AppColors.secondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _tarjeta(
                'Unidades',
                unidades,
                Icons.warehouse_outlined,
                Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _tarjeta(
                'Stock bajo',
                stockBajo,
                Icons.warning_amber_rounded,
                AppColors.accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _tarjeta(
                'Agotados',
                agotados,
                Icons.remove_shopping_cart_outlined,
                const Color(0xFFFF7777),
              ),
            ),
          ],
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
     margin: const EdgeInsets.only(left: 3, right: 3, bottom: 3),
      decoration: BoxDecoration(
                color: const Color.fromARGB(255, 164, 161, 161).withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12, width: 1),
        boxShadow: [
          BoxShadow(
                  color: Colors.white.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0,20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icono, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Estilotextos.textoPequeno,
                ),
              ),
            ],
          ),
          Text(
            '$valor',
            style: TextStyle(
              color: color,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
