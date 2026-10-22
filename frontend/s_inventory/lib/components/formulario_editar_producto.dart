
import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';

class FormularioEditarProducto {
  static Future<Map<String, String>?> mostrar(
    BuildContext context,
    Map<String, dynamic> producto,
  ) {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _DialogoEditarProducto(producto: producto),
    );
  }
}

class _DialogoEditarProducto extends StatefulWidget {
  final Map<String, dynamic> producto;

  const _DialogoEditarProducto({required this.producto});

  @override
  State<_DialogoEditarProducto> createState() =>
      _DialogoEditarProductoState();
}

class _DialogoEditarProductoState
    extends State<_DialogoEditarProducto> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;
  late final TextEditingController _precio;
  late final TextEditingController _categoria;
  late final TextEditingController _stock;

  @override
  void initState() {
    super.initState();

    final p = widget.producto;
    _nombre = TextEditingController(text: '${p['nombre'] ?? ''}');
    _descripcion = TextEditingController(
      text: '${p['descripcion'] ?? ''}',
    );
    _precio = TextEditingController(text: '${p['precio'] ?? ''}');
    _categoria = TextEditingController(
      text: '${p['categoria'] ?? ''}',
    );
    _stock = TextEditingController(text: '${p['stock'] ?? 0}');
  }

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    _precio.dispose();
    _categoria.dispose();
    _stock.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop({
      'nombre': _nombre.text.trim(),
      'descripcion': _descripcion.text.trim(),
      'precio': _precio.text.replaceAll(',', '.').trim(),
      'categoria': _categoria.text.trim(),
      'stock': _stock.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.fondoComponentes,
      title: const Text(
        'Editar producto',
        style: TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _campo(_nombre, 'Nombre'),
                _campo(_descripcion, 'Descripción', maxLines: 2),
                _campo(_precio, 'Precio', tipo: 'precio'),
                _campo(_categoria, 'Categoría - Tipo'),
                _campo(_stock, 'Stock', tipo: 'stock'),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        ElevatedButton(
          onPressed: _guardar,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.fondo,
          ),
          child: const Text('Guardar cambios'),
        ),
      ],
    );
  }

  Widget _campo(
    TextEditingController controller,
    String etiqueta, {
    String tipo = '',
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        keyboardType: tipo == 'precio'
            ? const TextInputType.numberWithOptions(decimal: true)
            : tipo == 'stock'
                ? TextInputType.number
                : TextInputType.text,
        decoration: InputDecoration(
          labelText: etiqueta,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.accent),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Campo obligatorio';
          }

          if (tipo == 'precio') {
            final numero = double.tryParse(
              value.replaceAll(',', '.'),
            );
            if (numero == null || numero <= 0) {
              return 'Precio inválido';
            }
          }

          if (tipo == 'stock') {
            final numero = int.tryParse(value);
            if (numero == null || numero < 0) {
              return 'Stock inválido';
            }
          }

          return null;
        },
      ),
    );
  }
}
