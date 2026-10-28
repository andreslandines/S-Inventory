
import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';

class ResumenVenta extends StatelessWidget {
  final String totalFormateado;
  final bool guardando;
  final bool carritoVacio;
  final VoidCallback onConfirmar;

  const ResumenVenta({
    super.key,
    required this.totalFormateado,
    required this.guardando,
    required this.carritoVacio,
    required this.onConfirmar,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        decoration: BoxDecoration(
          color: AppColors.fondoComponentes,
          border: Border(
            top: BorderSide(color: AppColors.bordeOscuro),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL DE LA VENTA',
                    style: TextStyle(
                      color: AppColors.textoSecundario,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    totalFormateado,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: carritoVacio || guardando
                  ? null
                  : onConfirmar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.fondo,
                disabledBackgroundColor: AppColors.bordeOscuro,
                disabledForegroundColor: Colors.white54,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: guardando
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline_rounded),
              label: Text(
                guardando ? 'Guardando' : 'Confirmar venta',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
