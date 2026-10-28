
import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';

class EstadoVenta extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final VoidCallback? onReintentar;

  const EstadoVenta({
    super.key,
    required this.icono,
    required this.titulo,
    required this.descripcion,
    this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icono,
              size: 54,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              descripcion,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textoSecundario,
                height: 1.5,
              ),
            ),
            if (onReintentar != null) ...[
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: onReintentar,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Intentar nuevamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
