
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:s_inventory/core/colores.dart';

import 'producto_widgets.dart';

class ProductoSelectorImagen extends StatelessWidget {
  final XFile? imagen;
  final bool usarUrl;
  final String url;
  final VoidCallback elegirGaleria;
  final VoidCallback elegirCamara;
  final VoidCallback cambiarModo;

  const ProductoSelectorImagen({
    super.key,
    required this.imagen,
    required this.usarUrl,
    required this.url,
    required this.elegirGaleria,
    required this.elegirCamara,
    required this.cambiarModo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 155,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.fondo,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: productoAzul.withValues(alpha: 0.35),
            ),
          ),
          child: _vistaPrevia(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _boton(
                Icons.photo_library_outlined,
                'Galería',
                elegirGaleria,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _boton(
                Icons.camera_alt_outlined,
                'Cámara',
                elegirCamara,
              ),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: cambiarModo,
          icon: Icon(
            usarUrl ? Icons.upload_file : Icons.link_rounded,
            color: productoAmarillo,
            size: 18,
          ),
          label: Text(
            usarUrl
                ? 'Elegir archivo o fotografía'
                : 'Usar URL de imagen',
            style: const TextStyle(color: productoAmarillo),
          ),
        ),
      ],
    );
  }

  Widget _vistaPrevia() {
    if (usarUrl && url.trim().isNotEmpty) {
      return Image.network(
        url.trim(),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _imagenVacia(),
      );
    }

    if (imagen != null) {
      return FutureBuilder<Uint8List>(
        future: imagen!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _imagenVacia();
          }

          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(
                color: productoAmarillo,
              ),
            );
          }

          final bytes = snapshot.data;

          if (bytes == null || bytes.isEmpty) {
            return _imagenVacia();
          }

          return Image.memory(
            bytes,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _imagenVacia(),
          );
        },
      );
    }

    return _imagenVacia();
  }

  Widget _imagenVacia() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          color: productoAzul,
          size: 42,
        ),
        SizedBox(height: 8),
        Text(
          'Vista previa del producto',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Selecciona una imagen para comenzar',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _boton(
    IconData icono,
    String texto,
    VoidCallback accion,
  ) {
    return OutlinedButton.icon(
      onPressed: accion,
      icon: Icon(icono, size: 18),
      label: Text(texto),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(
          color: productoAzul.withValues(alpha: 0.45),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
