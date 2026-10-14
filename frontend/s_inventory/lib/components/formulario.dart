import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:s_inventory/core/colores.dart';

class FormularioProducto {
  static Future<Map<String, dynamic>?> mostrar(
    BuildContext context,
  ) async {
    final formKey = GlobalKey<FormState>();

    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    final precioController = TextEditingController();
    final categoriaController = TextEditingController();
    final stockController = TextEditingController(text: '0');

    XFile? imagen;
    String? errorImagen;

    try {
      return await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          bool seleccionandoImagen = false;

          return StatefulBuilder(
            builder: (context, setDialogState) {
              OutlineInputBorder borde(Color color) {
                return OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: color),
                );
              }

              InputDecoration decoracion(String label) {
                return InputDecoration(
                  labelText: label,
                  labelStyle: const TextStyle(
                    color: Colors.white70,
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  enabledBorder: borde(Colors.white24),
                  focusedBorder: borde(Colors.white),
                  errorBorder: borde(Colors.redAccent),
                  focusedErrorBorder: borde(Colors.redAccent),
                );
              }

              Future<void> seleccionarImagen() async {
                setDialogState(() {
                  seleccionandoImagen = true;
                  errorImagen = null;
                });

                try {
                  final picker = ImagePicker();
                  final archivo = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                    maxWidth: 1200,
                  );

                  if (archivo != null) {
                    setDialogState(() {
                      imagen = archivo;
                    });
                  }
                } catch (_) {
                  setDialogState(() {
                    errorImagen = 'No se pudo seleccionar la imagen.';
                  });
                } finally {
                  setDialogState(() {
                    seleccionandoImagen = false;
                  });
                }
              }

              return AlertDialog(
                backgroundColor: AppColors.fondoComponentes,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: Colors.white24),
                ),
                title: const Text(
                  'Agregar producto',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SizedBox(
                  width: 420,
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: nombreController,
                            style: const TextStyle(color: Colors.white),
                            decoration: decoracion('Nombre *'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingresa el nombre';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: descripcionController,
                            style: const TextStyle(color: Colors.white),
                            maxLines: 2,
                            decoration: decoracion('Descripción'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: precioController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: decoracion('Precio *'),
                            validator: (value) {
                              final precio = double.tryParse(
                                (value ?? '').replaceAll(',', '.').trim(),
                              );

                              if (precio == null || precio <= 0) {
                                return 'Ingresa un precio válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: categoriaController,
                            style: const TextStyle(color: Colors.white),
                            decoration: decoracion('Categoría'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: stockController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            decoration: decoracion('Stock inicial'),
                            validator: (value) {
                              final stock = int.tryParse(
                                (value ?? '').trim(),
                              );

                              if (stock == null || stock < 0) {
                                return 'Ingresa un stock válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: seleccionandoImagen
                                  ? null
                                  : seleccionarImagen,
                              icon: const Icon(Icons.image_outlined),
                              label: Text(
                                seleccionandoImagen
                                    ? 'Seleccionando...'
                                    : imagen == null
                                        ? 'Seleccionar imagen *'
                                        : 'Cambiar imagen',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Colors.white38,
                                ),
                                padding: const EdgeInsets.all(14),
                              ),
                            ),
                          ),
                          if (imagen != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              imagen!.name,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (errorImagen != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              errorImagen!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                          if (imagen == null) ...[
                            const SizedBox(height: 6),
                            const Text(
                              'La imagen es obligatoria.',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;

                      if (imagen == null) {
                        setDialogState(() {
                          errorImagen = 'Selecciona una imagen del producto.';
                        });
                        return;
                      }

                      Navigator.pop(
                        dialogContext,
                        {
                          'nombre': nombreController.text.trim(),
                          'descripcion':
                              descripcionController.text.trim(),
                          'precio': precioController.text
                              .trim()
                              .replaceAll(',', '.'),
                          'categoria': categoriaController.text.trim(),
                          'stock': stockController.text.trim(),
                          'imagen': imagen,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.fondo,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Guardar producto'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      nombreController.dispose();
      descripcionController.dispose();
      precioController.dispose();
      categoriaController.dispose();
      stockController.dispose();
    }
  }
}