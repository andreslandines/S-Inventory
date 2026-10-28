
import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'producto_widgets.dart';

class ProductoCampoTexto extends StatelessWidget {
  final TextEditingController controller;
  final String etiqueta;
  final IconData icono;
  final String? Function(String?)? validator;
  final TextInputType? teclado;
  final int maxLineas;

  const ProductoCampoTexto({
    super.key,
    required this.controller,
    required this.etiqueta,
    required this.icono,
    this.validator,
    this.teclado,
    this.maxLineas = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      keyboardType: teclado,
      maxLines: maxLineas,
      validator: validator,
      decoration: ProductoEstilos.campo(etiqueta, icono),
    );
  }
}

class ProductoCampoSelector extends StatelessWidget {
  final String etiqueta;
  final IconData icono;
  final String? valor;
  final List<String> opciones;
  final ValueChanged<String?>? onChanged;
  final String? Function(String?)? validator;

  const ProductoCampoSelector({
    super.key,
    required this.etiqueta,
    required this.icono,
    required this.valor,
    required this.opciones,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: valor,
      isExpanded: true,
      dropdownColor: AppColors.fondoComponentes,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      iconEnabledColor: productoAmarillo,
      decoration: ProductoEstilos.campo(etiqueta, icono),
      items: opciones.map((opcion) {
        return DropdownMenuItem<String>(
          value: opcion,
          child: Text(
            opcion,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
