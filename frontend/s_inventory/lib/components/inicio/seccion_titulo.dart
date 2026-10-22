import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';

class SeccionTitulo extends StatelessWidget {
  final String titulo;
  final String? subtitulo;

  const SeccionTitulo({
    super.key,
    required this.titulo,
    this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitulo != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitulo!,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}