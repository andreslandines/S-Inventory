import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';


class UserService {
   // Petición POST para iniciar sesión (NUEVO, dentro de la misma clase)
Future<Map<String, dynamic>> loginUsuario(String email, String contrasena) async {
  final url = Uri.parse('${ApiConfig.baseUrl}/login');

  try {
    final response = await http.post(
      url,
      headers: ApiConfig.headers,
      body: jsonEncode({
        'email': email,
        'contrasena': contrasena,
      }),
    );

    final contentType = response.headers['content-type'] ?? '';

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
    
      // Devuelve el mapa completo con 'token' y 'usuario' tal como lo responde el backend
      return responseData;
    } else {
      if (contentType.contains('application/json')) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);

        // El backend Express envía el mensaje en la clave 'error'
        final String mensajeError =
            errorData['error'] ??
            errorData['message'] ??
            'Credenciales incorrectas';

        throw Exception(mensajeError);
      } else {
        throw Exception(
          'Servidor no disponible o ruta no encontrada (Código ${response.statusCode})',
        );
      }
    }
  } catch (e) {
    throw Exception(e.toString().replaceAll('Exception: ', ''));
  }
}

Future<Map<String, dynamic>> enviarCodigo(String email) async {
  final url = Uri.parse('${ApiConfig.baseUrl}/forgot-password');

  try {
    final response = await http.post(
      url,
      headers: ApiConfig.headers,
      body: jsonEncode({
        'email': email,
      }),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return responseData;
    } else {
      throw Exception(
        responseData['error'] ?? 'Error al enviar el código',
      );
    }
  } catch (e) {
    throw Exception(
      e.toString().replaceAll('Exception: ', ''),
    );
  }
}

Future<Map<String, dynamic>> verificarCodigo(
  String email,
  String codigo,
  String newPasswords,
) async {
  final url = Uri.parse('${ApiConfig.baseUrl}/verify-code');

  try {
    final response = await http.post(
      url,
      headers: ApiConfig.headers,
      body: jsonEncode({
        'email': email,
        'codigo': codigo,
        'newPasswords': newPasswords,
      }),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return responseData;
    } else {
      throw Exception(
        responseData['error'] ?? 'Error al verificar el código',
      );
    }
  } catch (e) {
    throw Exception(
      e.toString().replaceAll('Exception: ', ''),
    );
  }
}
}