
import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';

class BuscadorVenta extends StatelessWidget {
  final TextEditingController controller;
  final String busqueda;
  final ValueChanged<String> onChanged;

  const BuscadorVenta({
    super.key,
    required this.controller,
    required this.busqueda,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Buscar por nombre del producto...',
        hintStyle: const TextStyle(
          color: Colors.white54,
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.secondary,
        ),
        suffixIcon: busqueda.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.white60,
                ),
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
