
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class VentaService {
  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    return {
      ...ApiConfig.headers,
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  Future<List<Map<String, dynamic>>> obtenerVentas() async {
    final respuesta = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/ventas/'),
      headers: await _headers(),
    );

    if (respuesta.statusCode != 200) {
      throw Exception('No se pudieron consultar las ventas.');
    }

    final datos = jsonDecode(respuesta.body);

    if (datos is! List) {
      throw Exception('La respuesta de ventas no es válida.');
    }

    return datos
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }

  Future<Map<String, dynamic>> registrarVenta({
    required String idUsuario,
    required List<Map<String, dynamic>> productos,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final idGuardado = prefs.getString('id_usuario');

    if (idGuardado == null || idGuardado.isEmpty) {
      throw Exception(
        'No se encontró el ID del usuario. '
        'Cierra sesión e inicia nuevamente.',
      );
    }

    final idNumerico = int.tryParse(idGuardado);

    if (idNumerico == null || idNumerico <= 0) {
      throw Exception('El ID guardado del usuario no es válido.');
    }

    // Verifica que el ID entregado por la pantalla coincida
    // con el ID guardado al iniciar sesión.
    final idRecibido = int.tryParse(idUsuario);

    if (idRecibido != null && idRecibido != idNumerico) {
      throw Exception('El ID del usuario no coincide.');
    }

    if (productos.isEmpty) {
      throw Exception('Debes agregar al menos un producto.');
    }

    final respuesta = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/ventas/registrar'),
      headers: await _headers(),
      body: jsonEncode({
        'id_usuario': idNumerico,
        'productos': productos,
      }),
    );

    Map<String, dynamic> datos = {};

    if (respuesta.body.isNotEmpty) {
      final json = jsonDecode(respuesta.body);

      if (json is Map<String, dynamic>) {
        datos = json;
      }
    }

    if (respuesta.statusCode == 201) {
      return datos;
    }

    throw Exception(
      datos['error']?.toString() ??
          'No se pudo registrar la venta. '
          'Código HTTP: ${respuesta.statusCode}',
    );
  }

  Future<Map<String, dynamic>> obtenerVentaPorId(
  String idVenta,
) async {
  final respuesta = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/ventas/$idVenta'),
    headers: await _headers(),
  );

  if (respuesta.statusCode != 200) {
    throw Exception(
      'No se pudo consultar el recibo de la venta.',
    );
  }

  final datos = jsonDecode(respuesta.body);

  if (datos is Map<String, dynamic>) {
    return datos;
  }

  throw Exception('La información del recibo no es válida.');
}
}
