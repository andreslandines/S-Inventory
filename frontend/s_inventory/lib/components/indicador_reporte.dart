import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';

class IndicadorReporte extends StatelessWidget {
  final String titulo;
  final String valor;
  final String descripcion;
  final IconData icono;
  final Color color;

  const IndicadorReporte({
    super.key,
    required this.titulo,
    required this.valor,
    required this.descripcion,
    required this.icono,
    this.color = AppColors.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.09),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.17),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: color, size: 23),
          ),
          const SizedBox(height: 13),
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            descripcion,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}