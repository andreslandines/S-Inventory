
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'producto_widgets.dart';
import 'producto_campos.dart';
import 'producto_imagen.dart';

class ProductoFormularioContenido extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nombre;
  final TextEditingController descripcion;
  final TextEditingController precio;
  final TextEditingController stock;
  final TextEditingController url;
  final TextEditingController otroTipo;

  final XFile? imagen;
  final bool usarUrl;
  final String? categoria;
  final String? tipo;
  final Map<String, List<String>> categorias;

  final ValueChanged<XFile> seleccionarImagen;
  final VoidCallback cambiarModoImagen;
  final ValueChanged<String?> cambiarCategoria;
  final ValueChanged<String?> cambiarTipo;
  final String? Function(String?) requerido;
  final VoidCallback guardar;
  final VoidCallback cancelar;

  const ProductoFormularioContenido({
    super.key,
    required this.formKey,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
    required this.url,
    required this.otroTipo,
    required this.imagen,
    required this.usarUrl,
    required this.categoria,
    required this.tipo,
    required this.categorias,
    required this.seleccionarImagen,
    required this.cambiarModoImagen,
    required this.cambiarCategoria,
    required this.cambiarTipo,
    required this.requerido,
    required this.guardar,
    required this.cancelar,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
              elegirGaleria: () => _elegir(context, ImageSource.gallery),
              elegirCamara: () => _elegir(context, ImageSource.camera),
              cambiarModo: cambiarModoImagen,
            ),
            if (usarUrl) ...[
              const SizedBox(height: 12),
              ProductoCampoTexto(
                controller: url,
                etiqueta: 'URL de la imagen *',
                icono: Icons.link,
                validator: (v) {
                  final uri = Uri.tryParse(v?.trim() ?? '');
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
              validator: (v) =>
                  v == null ? 'Selecciona una categoría' : null,
              onChanged: cambiarCategoria,
            ),
            const SizedBox(height: 12),
            ProductoCampoSelector(
              etiqueta: 'Tipo de producto *',
              icono: Icons.sell_outlined,
              valor: tipo,
              opciones: categorias[categoria] ?? [],
              validator: (v) =>
                  v == null ? 'Selecciona un tipo' : null,
              onChanged: categoria == null ? null : cambiarTipo,
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
                      return s == null || s < 0 ? 'Stock inválido' : null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: guardar,
                icon: const Icon(Icons.save_rounded),
                label: const Text(
                  'Guardar producto',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: productoAmarillo,
                  foregroundColor: const Color(0xFF0E2136),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: cancelar,
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _elegir(BuildContext context, ImageSource source) async {
    final archivo = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (archivo != null) seleccionarImagen(archivo);
  }
}
