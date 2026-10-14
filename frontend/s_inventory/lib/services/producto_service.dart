import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class ProductoService {
  Future<List<Map<String, dynamic>>> obtenerProductos() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/pro/productos');

    final respuesta = await http.get(
      url,
      headers: ApiConfig.headers,
    );

    if (respuesta.statusCode == 200) {
      final dynamic datos = jsonDecode(respuesta.body);

      if (datos is! List) {
        throw Exception('La respuesta de productos no es una lista');
      }

      return datos.map<Map<String, dynamic>>((producto) {
        return Map<String, dynamic>.from(producto);
      }).toList();
    }

    throw Exception(
      'Error al consultar productos: ${respuesta.statusCode}',
    );
  }

  Future<Map<String, dynamic>> crearProducto({
    required String nombre,
    required String descripcion,
    required String precio,
    required String categoria,
    required String stock,
    required List<int> imagenBytes,
    required String nombreImagen,
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

    solicitud.files.add(
      http.MultipartFile.fromBytes(
        'imagen',
        imagenBytes,
        filename: nombreImagen,
      ),
    );

    final respuesta = await solicitud.send();
    final cuerpo = await respuesta.stream.bytesToString();

    Map<String, dynamic> datos = {};

    if (cuerpo.isNotEmpty) {
      try {
        final decoded = jsonDecode(cuerpo);
        if (decoded is Map<String, dynamic>) {
          datos = decoded;
        }
      } catch (_) {
        throw Exception(
          'El servidor devolvió una respuesta no válida.',
        );
      }
    }

    if (respuesta.statusCode == 201) {
      return datos;
    }

    final mensaje = datos['error'] ??
        datos['message'] ??
        'No se pudo registrar el producto '
            '(código ${respuesta.statusCode}).';

    throw Exception(mensaje.toString());
  }
}