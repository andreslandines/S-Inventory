
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import 'api_config.dart';

class ProductoService {
  Future<List<Map<String, dynamic>>> obtenerProductos() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/pro/productos');

    final respuesta = await http.get(
      url,
      headers: ApiConfig.headers,
    );

    if (respuesta.statusCode != 200) {
      throw Exception(
        'Error al consultar productos: ${respuesta.statusCode}',
      );
    }

    final dynamic datos = jsonDecode(respuesta.body);

    if (datos is! List) {
      throw Exception('La respuesta de productos no es una lista.');
    }

    return datos.map<Map<String, dynamic>>((producto) {
      return Map<String, dynamic>.from(producto);
    }).toList();
  }

  Future<Map<String, dynamic>> crearProducto({
    required String nombre,
    required String descripcion,
    required String precio,
    required String categoria,
    required String stock,
    List<int>? imagenBytes,
    String? nombreImagen,
    String? imagenUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception(
        'No se encontró el token. Inicia sesión nuevamente.',
      );
    }

    final url = Uri.parse(
      '${ApiConfig.baseUrl}/pro/productoscrear',
    );

    final solicitud = http.MultipartRequest('POST', url);

    solicitud.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    solicitud.fields.addAll({
      'nombre': nombre.trim(),
      'descripcion': descripcion.trim(),
      'precio': precio.trim(),
      'categoria': categoria.trim(),
      'stock': stock.trim(),
    });

    final urlImagen = imagenUrl?.trim() ?? '';

    if (imagenBytes != null && imagenBytes.isNotEmpty) {
      solicitud.files.add(
        http.MultipartFile.fromBytes(
          'imagen',
          imagenBytes,
          filename: nombreImagen ?? 'producto.jpg',
        ),
      );
    } else if (urlImagen.isNotEmpty) {
      solicitud.fields['imagenUrl'] = urlImagen;
    } else {
      throw Exception(
        'Selecciona una imagen o proporciona una URL válida.',
      );
    }

    final respuesta = await solicitud.send();
    final cuerpo = await respuesta.stream.bytesToString();

    final datos = _decodificarRespuesta(cuerpo);

    if (respuesta.statusCode == 200 ||
        respuesta.statusCode == 201) {
      return datos;
    }

    throw Exception(
      datos['error'] ??
          datos['message'] ??
          'No se pudo registrar el producto '
              '(código ${respuesta.statusCode}).',
    );
  }

  // ACTUALIZAR PRODUCTO E IMAGEN
  Future<void> actualizarProducto({
    required String id,
    required String nombre,
    required String descripcion,
    required String precio,
    required String categoria,
    required String stock,
    XFile? imagenArchivo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception('Inicia sesión nuevamente.');
    }

    final url = Uri.parse(
      '${ApiConfig.baseUrl}/pro/productoseditar/$id',
    );

    final solicitud = http.MultipartRequest('PUT', url);

    solicitud.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    solicitud.fields.addAll({
      'nombre': nombre.trim(),
      'descripcion': descripcion.trim(),
      'precio': double.parse(
        precio.replaceAll(',', '.'),
      ).toString(),
      'categoria': categoria.trim(),
      'stock': int.parse(stock).toString(),
    });

    // Solo se adjunta la imagen cuando el usuario selecciona otra.
    if (imagenArchivo != null) {
      final bytes = await imagenArchivo.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception('La imagen seleccionada está vacía.');
      }

      solicitud.files.add(
        http.MultipartFile.fromBytes(
          'imagen',
          bytes,
          filename: imagenArchivo.name,
        ),
      );
    }

    final respuesta = await solicitud.send();
    final cuerpo = await respuesta.stream.bytesToString();

    final datos = _decodificarRespuesta(cuerpo);

    if (respuesta.statusCode == 200 ||
        respuesta.statusCode == 201) {
      return;
    }

    throw Exception(
      datos['error'] ??
          datos['message'] ??
          'No se pudo actualizar el producto '
              '(código ${respuesta.statusCode}).',
    );
  }

  Future<void> eliminarProducto(String id) async {
    final idProducto = id.trim();

    if (idProducto.isEmpty || idProducto == 'null') {
      throw Exception(
        'El identificador del producto no es válido.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception('Inicia sesión nuevamente.');
    }

    final url = Uri.parse(
      '${ApiConfig.baseUrl}/pro/productoseliminar/$idProducto',
    );

    final respuesta = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (respuesta.statusCode == 200 ||
        respuesta.statusCode == 204) {
      return;
    }

    String detalle = respuesta.body.trim();

    if (detalle.isNotEmpty) {
      try {
        final datos = jsonDecode(detalle);

        if (datos is Map) {
          detalle = datos['error']?.toString() ??
              datos['message']?.toString() ??
              detalle;
        }
      } catch (_) {}
    }

    throw Exception(
      'Error al eliminar producto '
      '(HTTP ${respuesta.statusCode}): $detalle',
    );
  }

  Map<String, dynamic> _decodificarRespuesta(String cuerpo) {
    if (cuerpo.isEmpty) return {};

    try {
      final decoded = jsonDecode(cuerpo);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      return {};
    } catch (_) {
      throw Exception(
        'El servidor devolvió una respuesta no válida.',
      );
    }
  }
}
