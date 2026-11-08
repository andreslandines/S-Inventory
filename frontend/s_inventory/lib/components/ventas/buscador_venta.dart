
import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';

class BuscadorVenta extends StatelessWidget {
  final TextEditingController controller;
  final String busqueda;
  final ValueChanged<String> onChanged;
  final VoidCallback onEscanear;

  const BuscadorVenta({
    super.key,
    required this.controller,
    required this.busqueda,
    required this.onChanged,
    required this.onEscanear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Buscar por nombre o código de barras...',
        hintStyle: const TextStyle(
          color: Colors.white54,
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.secondary,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Escanear código de barras',
              onPressed: onEscanear,
              icon: const Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.accent,
              ),
            ),
            if (busqueda.isNotEmpty)
              IconButton(
                tooltip: 'Limpiar búsqueda',
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.white60,
                ),
              ),
          ],
        ),
        filled: true,
        fillColor: AppColors.fondoComponentes,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }
}
