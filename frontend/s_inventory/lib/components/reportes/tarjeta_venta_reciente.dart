import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';

class TarjetaVentaReciente extends StatelessWidget {
  final Map<String, dynamic> venta;

  const TarjetaVentaReciente({
    super.key,
    required this.venta,
  });

  @override
  Widget build(BuildContext context) {
    final id = venta['id_venta']?.toString() ?? '-';
    final total = double.tryParse(
          venta['total']?.toString() ?? '',
        ) ??
        0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.fondoComponentes,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(
              Icons.receipt_long,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Venta #$id',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '\$${total.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}