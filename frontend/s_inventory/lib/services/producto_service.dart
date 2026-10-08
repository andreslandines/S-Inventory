import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductoService {
  static const String baseUrl = 'http://localhost:3000';

  Future<List<Map<String, dynamic>>> obtenerProductos() async {
    final url = Uri.parse('$baseUrl/pro/productos');

    final respuesta = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
      },
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
}