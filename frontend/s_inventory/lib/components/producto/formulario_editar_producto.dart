
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:s_inventory/core/colores.dart';

class FormularioEditarProducto {
  static Future<Map<String, dynamic>?> mostrar(
    BuildContext context,
    Map<String, dynamic> producto,
  ) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
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
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;
  late final TextEditingController _precio;
  late final TextEditingController _categoria;
  late final TextEditingController _stock;

  XFile? _imagenSeleccionada;
  Uint8List? _imagenBytes;
  bool _cargandoImagen = false;

  String get _imagenActual =>
      '${widget.producto['imagen'] ?? ''}';

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

  Future<void> _seleccionarImagen(ImageSource origen) async {
    try {
      final XFile? archivo = await _picker.pickImage(
        source: origen,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (archivo == null) return;

      setState(() => _cargandoImagen = true);

      final bytes = await archivo.readAsBytes();

      if (!mounted) return;

      setState(() {
        _imagenSeleccionada = archivo;
        _imagenBytes = bytes;
        _cargandoImagen = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _cargandoImagen = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo cargar la imagen'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF17263B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Cambiar fotografía',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.secondary,
                  ),
                  title: const Text(
                    'Seleccionar de galería',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _seleccionarImagen(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.secondary,
                  ),
                  title: const Text(
                    'Tomar fotografía',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _seleccionarImagen(ImageSource.camera);
                  },
                ),
                if (_imagenSeleccionada != null)
                  ListTile(
                    leading: const Icon(
                      Icons.restore_rounded,
                      color: Colors.orangeAccent,
                    ),
                    title: const Text(
                      'Conservar imagen anterior',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _imagenSeleccionada = null;
                        _imagenBytes = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _vistaPreviaImagen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fotografía del producto',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: 105,
                height: 105,
                color: Colors.white.withOpacity(0.06),
                child: _cargandoImagen
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      )
                    : _imagenBytes != null
                        ? Image.memory(
                            _imagenBytes!,
                            fit: BoxFit.cover,
                            width: 105,
                            height: 105,
                          )
                        : _imagenActual.isNotEmpty
                            ? Image.network(
                                _imagenActual,
                                fit: BoxFit.cover,
                                width: 105,
                                height: 105,
                                errorBuilder: (_, __, ___) =>
                                    _imagenVacia(),
                              )
                            : _imagenVacia(),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Puedes seleccionar una imagen o tomar una nueva.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _cargandoImagen
                        ? null
                        : _mostrarOpcionesImagen,
                    icon: const Icon(
                      Icons.add_a_photo_outlined,
                      size: 17,
                    ),
                    label: Text(
                      _imagenSeleccionada == null
                          ? 'Cambiar imagen'
                          : 'Elegir otra',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: BorderSide(
                        color: AppColors.secondary.withOpacity(0.6),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _imagenVacia() {
    return const Center(
      child: Icon(
        Icons.inventory_2_outlined,
        color: Colors.white38,
        size: 38,
      ),
    );
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    if (_cargandoImagen) return;

    Navigator.of(context).pop({
      'nombre': _nombre.text.trim(),
      'descripcion': _descripcion.text.trim(),
      'precio': _precio.text.replaceAll(',', '.').trim(),
      'categoria': _categoria.text.trim(),
      'stock': _stock.text.trim(),

      // URL anterior y archivo nuevo, si se seleccionó uno.
      'imagen': _imagenActual,
      'imagenArchivo': _imagenSeleccionada,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        decoration: BoxDecoration(
          color: AppColors.fondoComponentes.withOpacity(0.97),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          color: AppColors.secondary,
                          size: 27,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Editar producto',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Modifica la información necesaria',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Cerrar',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _vistaPreviaImagen(),

                  _campo(
                    _nombre,
                    'Nombre del producto',
                    icono: Icons.inventory_2_outlined,
                  ),
                  _campo(
                    _descripcion,
                    'Descripción',
                    icono: Icons.description_outlined,
                    maxLines: 3,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _campo(
                          _precio,
                          'Precio',
                          icono: Icons.attach_money_rounded,
                          tipo: 'precio',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _campo(
                          _stock,
                          'Stock',
                          icono: Icons.warehouse_outlined,
                          tipo: 'stock',
                        ),
                      ),
                    ],
                  ),

                  _campo(
                    _categoria,
                    'Categoría - Tipo',
                    icono: Icons.category_outlined,
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.18),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _cargandoImagen ? null : _guardar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.fondo,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          icon: const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 19,
                          ),
                          label: const Text(
                            'Guardar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(
    TextEditingController controller,
    String etiqueta, {
    required IconData icono,
    String tipo = '',
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        cursorColor: AppColors.accent,
        keyboardType: tipo == 'precio'
            ? const TextInputType.numberWithOptions(decimal: true)
            : tipo == 'stock'
                ? TextInputType.number
                : TextInputType.text,
        decoration: InputDecoration(
          labelText: etiqueta,
          labelStyle: const TextStyle(color: Colors.white60),
          prefixIcon: Icon(
            icono,
            color: Colors.white54,
            size: 20,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.045),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.10),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(
              color: AppColors.accent,
              width: 1.4,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(
              color: Color(0xFFFF7777),
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(
              color: Color(0xFFFF7777),
            ),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Campo obligatorio';
          }

          if (tipo == 'precio') {
            final numero = double.tryParse(
              value.replaceAll(',', '.').trim(),
            );

            if (numero == null || numero <= 0) {
              return 'Precio inválido';
            }
          }

          if (tipo == 'stock') {
            final numero = int.tryParse(value.trim());

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
