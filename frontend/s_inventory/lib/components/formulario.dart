
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:s_inventory/core/colores.dart';

class FormularioProducto {
  static const categorias = {
    'Aseo y limpieza': [
      'Detergente', 'Suavizante', 'Jabón para ropa',
      'Lavaloza', 'Desinfectante', 'Cloro', 'Otro',
    ],
    'Cuidado personal': [
      'Jabón de baño', 'Champú', 'Acondicionador',
      'Desodorante', 'Crema dental', 'Otro',
    ],
    'Alimentos y abarrotes': [
      'Arroz', 'Pasta', 'Harina', 'Azúcar',
      'Sal', 'Aceite', 'Granos', 'Enlatados', 'Otro',
    ],
    'Bebidas': [
      'Agua', 'Gaseosa', 'Jugos', 'Café', 'Té', 'Otro',
    ],
    'Lácteos y huevos': [
      'Leche', 'Queso', 'Yogur', 'Mantequilla', 'Huevos', 'Otro',
    ],
    'Frutas y verduras': [
      'Frutas', 'Verduras', 'Tubérculos', 'Hierbas', 'Otro',
    ],
    'Panadería y snacks': [
      'Pan', 'Galletas', 'Pasteles', 'Papas fritas', 'Dulces', 'Otro',
    ],
    'Mascotas': [
      'Alimento para perros', 'Alimento para gatos',
      'Arena sanitaria', 'Otro',
    ],
    'Bebés': [
      'Pañales', 'Toallitas húmedas', 'Fórmula infantil', 'Otro',
    ],
    'Papelería y hogar': [
      'Cuadernos', 'Lápices', 'Papel', 'Servilletas',
      'Papel higiénico', 'Otro',
    ],
    'Otros': ['Otro'],
  };

  static Future<Map<String, dynamic>?> mostrar(
    BuildContext context,
  ) async {
    final formKey = GlobalKey<FormState>();
    final nombre = TextEditingController();
    final descripcion = TextEditingController();
    final precio = TextEditingController();
    final stock = TextEditingController(text: '0');
    final url = TextEditingController();
    final otroTipo = TextEditingController();

    XFile? imagen;
    String? categoria;
    String? tipo;
    bool usarUrl = false;

    InputDecoration campo(String texto) => InputDecoration(
          labelText: texto,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.accent),
          ),
        );

    String? requerido(String? v) =>
        v == null || v.trim().isEmpty ? 'Campo obligatorio' : null;

    try {
      return await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, actualizar) {
            final tipos = categorias[categoria] ?? [];

            Future<void> elegirImagen(ImageSource source) async {
              final archivo = await ImagePicker().pickImage(
                source: source,
                imageQuality: 80,
                maxWidth: 1200,
              );

              if (archivo != null) {
                actualizar(() {
                  imagen = archivo;
                  usarUrl = false;
                  url.clear();
                });
              }
            }

            return AlertDialog(
              backgroundColor: AppColors.fondoComponentes,
              title: const Text(
                'Agregar producto',
                style: TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 130,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.fondo,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: usarUrl && url.text.isNotEmpty
                              ? Image.network(
                                  url.text,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.white54,
                                  ),
                                )
                              : imagen != null
                                  ? FutureBuilder(
                                      future: imagen!.readAsBytes(),
                                      builder: (_, snapshot) =>
                                          snapshot.hasData
                                              ? Image.memory(
                                                  snapshot.data!,
                                                  fit: BoxFit.contain,
                                                )
                                              : const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                    )
                                  : const Icon(
                                      Icons.add_photo_alternate_outlined,
                                      color: Colors.white54,
                                      size: 42,
                                    ),
                        ),
                        Wrap(
                          spacing: 8,
                          children: [
                            TextButton.icon(
                              onPressed: () =>
                                  elegirImagen(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_outlined),
                              label: const Text('Galería'),
                            ),
                            TextButton.icon(
                              onPressed: () =>
                                  elegirImagen(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt_outlined),
                              label: const Text('Cámara'),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => actualizar(() {
                            usarUrl = !usarUrl;
                            imagen = null;
                            url.clear();
                          }),
                          child: Text(
                            usarUrl ? 'Usar archivo' : 'Usar URL de imagen',
                            style: TextStyle(color: AppColors.accent),
                          ),
                        ),
                        if (usarUrl)
                          TextFormField(
                            controller: url,
                            style: const TextStyle(color: Colors.white),
                            decoration: campo('URL de imagen'),
                            validator: (v) {
                              if (!usarUrl) return null;
                              final uri = Uri.tryParse(v?.trim() ?? '');
                              if (uri == null ||
                                  !uri.hasAuthority ||
                                  !['http', 'https'].contains(uri.scheme)) {
                                return 'Ingresa una URL válida';
                              }
                              return null;
                            },
                            onChanged: (_) => actualizar(() {}),
                          ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: nombre,
                          style: const TextStyle(color: Colors.white),
                          decoration: campo('Nombre *'),
                          validator: requerido,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: descripcion,
                          style: const TextStyle(color: Colors.white),
                          decoration: campo('Descripción'),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: precio,
                          style: const TextStyle(color: Colors.white),
                          decoration: campo('Precio *'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) {
                            final p = double.tryParse(
                              (v ?? '').replaceAll(',', '.'),
                            );
                            return p == null || p <= 0
                                ? 'Precio inválido'
                                : null;
                          },
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: categoria,
                          isExpanded: true,
                          dropdownColor: AppColors.fondoComponentes,
                          style: const TextStyle(color: Colors.white),
                          decoration: campo('Categoría *'),
                          items: categorias.keys
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ))
                              .toList(),
                          onChanged: (v) => actualizar(() {
                            categoria = v;
                            tipo = null;
                            otroTipo.clear();
                          }),
                          validator: (v) =>
                              v == null ? 'Elige una categoría' : null,
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: tipo,
                          isExpanded: true,
                          dropdownColor: AppColors.fondoComponentes,
                          style: const TextStyle(color: Colors.white),
                          decoration: campo('Tipo de producto *'),
                          items: tipos
                              .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t),
                                  ))
                              .toList(),
                          onChanged: categoria == null
                              ? null
                              : (v) => actualizar(() {
                                    tipo = v;
                                    otroTipo.clear();
                                  }),
                          validator: (v) =>
                              v == null ? 'Elige un tipo' : null,
                        ),
                        if (tipo == 'Otro') ...[
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: otroTipo,
                            style: const TextStyle(color: Colors.white),
                            decoration: campo('Especifica el tipo *'),
                            validator: requerido,
                          ),
                        ],
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: stock,
                          style: const TextStyle(color: Colors.white),
                          decoration: campo('Stock inicial'),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final s = int.tryParse(v ?? '');
                            return s == null || s < 0
                                ? 'Stock inválido'
                                : null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    if (!usarUrl && imagen == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selecciona una imagen'),
                        ),
                      );
                      return;
                    }

                    final tipoFinal = tipo == 'Otro'
                        ? otroTipo.text.trim()
                        : tipo!;

                    Navigator.pop(dialogContext, {
                      'nombre': nombre.text.trim(),
                      'descripcion': descripcion.text.trim(),
                      'precio': precio.text.replaceAll(',', '.').trim(),
                      'categoria': '$categoria - $tipoFinal',
                      'tipoProducto': tipoFinal,
                      'stock': stock.text.trim(),
                      'imagen': imagen,
                      'imagenUrl': usarUrl ? url.text.trim() : null,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.fondo,
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        ),
      );
    } finally {
      nombre.dispose();
      descripcion.dispose();
      precio.dispose();
      stock.dispose();
      url.dispose();
      otroTipo.dispose();
    }
  }
}
