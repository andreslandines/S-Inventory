
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:s_inventory/core/colores.dart';
import 'producto_widgets.dart';
import 'producto_campos.dart';
import 'producto_imagen.dart';

class FormularioProducto {
static const Map<String, List<String>> categorias = {
  'Aseo y limpieza': ['Otro'],
  'Cuidado personal y belleza': ['Otro'],
  'Higiene femenina': ['Otro'],
  'Bebés y maternidad': ['Otro'],
  'Frutas, verduras y tubérculos': ['Otro'],
  'Alimentos y abarrotes': ['Otro'],
  'Enlatados y conservas': ['Otro'],
  'Lácteos y derivados': ['Otro'],
  'Bebidas': ['Otro'],
  'Helados y congelados': ['Otro'],
  'Panadería y comidas preparadas': ['Otro'],
  'Dulces, galletas y snacks': ['Otro'],
  'Salsas y condimentos': ['Otro'],
  'Ropa y calzado': ['Otro'],
  'Accesorios y bisutería': ['Otro'],
  'Papelería y útiles escolares': ['Otro'],
  'Manualidades y costura': ['Otro'],
  'Ferretería y plomería': ['Otro'],
  'Electricidad e iluminación': ['Otro'],
  'Droguería y primeros auxilios': ['Otro'],
  'Cigarrillos y encendedores': ['Otro'],
  'Hogar, desechables y empaques': ['Otro'],
  'Mascotas': ['Otro'],
  'Velas y artículos para fiestas': ['Otro'],
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

    String? requerido(String? valor) =>
        valor == null || valor.trim().isEmpty
            ? 'Este campo es obligatorio'
            : null;

    try {
      return await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, actualizar) {
            Future<void> elegirImagen(ImageSource source) async {
              try {
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
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No se pudo seleccionar la imagen.'),
                    ),
                  );
                }
              }
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 22,
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                decoration: BoxDecoration(
                  color: AppColors.fondo,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: productoAzul.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _encabezado(dialogContext),
                    Container(height: 1, color: Colors.white10),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const ProductoSeccion(
                                titulo: 'Imagen del producto',
                                icono: Icons.photo_camera_outlined,
                              ),
                              ProductoSelectorImagen(
                                imagen: imagen,
                                usarUrl: usarUrl,
                                url: url.text,
                                elegirGaleria: () =>
                                    elegirImagen(ImageSource.gallery),
                                elegirCamara: () =>
                                    elegirImagen(ImageSource.camera),
                                cambiarModo: () => actualizar(() {
                                  usarUrl = !usarUrl;
                                  imagen = null;
                                  url.clear();
                                }),
                              ),
                              if (usarUrl) ...[
                                const SizedBox(height: 12),
                                ProductoCampoTexto(
                                  controller: url,
                                  etiqueta: 'URL de la imagen *',
                                  icono: Icons.link,
                                  validator: (valor) {
                                    final uri = Uri.tryParse(
                                      valor?.trim() ?? '',
                                    );
                                    if (uri == null ||
                                        !uri.hasAuthority ||
                                        !['http', 'https'].contains(uri.scheme)) {
                                      return 'Ingresa una URL válida';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                              const ProductoSeccion(
                                titulo: 'Información básica',
                                icono: Icons.edit_note_rounded,
                              ),
                              ProductoCampoTexto(
                                controller: nombre,
                                etiqueta: 'Nombre del producto *',
                                icono: Icons.inventory_2_outlined,
                                validator: requerido,
                              ),
                              const SizedBox(height: 12),
                              ProductoCampoTexto(
                                controller: descripcion,
                                etiqueta: 'Descripción',
                                icono: Icons.notes_rounded,
                                maxLineas: 2,
                              ),
                              const ProductoSeccion(
                                titulo: 'Categoría y tipo',
                                icono: Icons.category_outlined,
                              ),
                              ProductoCampoSelector(
                                etiqueta: 'Categoría *',
                                icono: Icons.grid_view_rounded,
                                valor: categoria,
                                opciones: categorias.keys.toList(),
                                validator: (v) => v == null
                                    ? 'Selecciona una categoría'
                                    : null,
                                onChanged: (v) => actualizar(() {
                                  categoria = v;
                                  tipo = null;
                                  otroTipo.clear();
                                }),
                              ),
                              const SizedBox(height: 12),
                              ProductoCampoSelector(
                                etiqueta: 'Tipo de producto *',
                                icono: Icons.sell_outlined,
                                valor: tipo,
                                opciones: categorias[categoria] ?? [],
                                validator: (v) => v == null
                                    ? 'Selecciona un tipo'
                                    : null,
                                onChanged: categoria == null
                                    ? null
                                    : (v) => actualizar(() {
                                          tipo = v;
                                          otroTipo.clear();
                                        }),
                              ),
                              if (tipo == 'Otro') ...[
                                const SizedBox(height: 12),
                                ProductoCampoTexto(
                                  controller: otroTipo,
                                  etiqueta: 'Especifica el tipo *',
                                  icono: Icons.edit_rounded,
                                  validator: requerido,
                                ),
                              ],
                              const ProductoSeccion(
                                titulo: 'Precio y existencias',
                                icono: Icons.price_change_outlined,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ProductoCampoTexto(
                                      controller: precio,
                                      etiqueta: 'Precio *',
                                      icono: Icons.attach_money_rounded,
                                      teclado: const TextInputType.numberWithOptions(
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
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ProductoCampoTexto(
                                      controller: stock,
                                      etiqueta: 'Stock inicial',
                                      icono: Icons.inventory_outlined,
                                      teclado: TextInputType.number,
                                      validator: (v) {
                                        final s = int.tryParse(v ?? '');
                                        return s == null || s < 0
                                            ? 'Stock inválido'
                                            : null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              _botonGuardar(() {
                                if (!formKey.currentState!.validate()) return;

                                if (!usarUrl && imagen == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Selecciona una imagen o utiliza una URL.',
                                      ),
                                      behavior: SnackBarBehavior.floating,
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
                                  'precio': precio.text
                                      .replaceAll(',', '.')
                                      .trim(),
                                  'categoria': '$categoria - $tipoFinal',
                                  'tipoProducto': tipoFinal,
                                  'stock': stock.text.trim(),
                                  'imagen': imagen,
                                  'imagenUrl':
                                      usarUrl ? url.text.trim() : null,
                                });
                              }),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: OutlinedButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white70,
                                    side: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.18,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text('Cancelar'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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

  static Widget _encabezado(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 12, 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: productoAmarillo.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: productoAmarillo,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registrar producto',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Agrega un producto a tu inventario',
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  static Widget _botonGuardar(VoidCallback accion) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: accion,
        icon: const Icon(Icons.save_rounded),
        label: const Text(
          'Guardar producto',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: productoAmarillo,
          foregroundColor: const Color(0xFF0E2136),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
