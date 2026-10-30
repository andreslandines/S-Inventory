
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class UserService {
  // Iniciar sesión.
  Future<Map<String, dynamic>> loginUsuario(
    String email,
    String contrasena,
  ) async {
    final url = Uri.parse('${ApiConfig.authBaseUrl}/login');

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({
          'email': email.trim(),
          'contrasena': contrasena,
        }),
      );

      final responseData = _decodificarRespuesta(response);

      if (response.statusCode == 200) {
        return responseData;
      }

      throw Exception(
        responseData['error'] ??
            responseData['message'] ??
            'Credenciales incorrectas.',
      );
    } catch (e) {
      throw Exception(_limpiarError(e));
    }
  }

  // Enviar código de recuperación al correo.
  Future<Map<String, dynamic>> enviarCodigo(String email) async {
    final correo = email.trim();
    final url = Uri.parse('${ApiConfig.authBaseUrl}/forgot-password');

    if (correo.isEmpty) {
      throw Exception('Ingresa tu correo electrónico.');
    }

    try {
      print('RECUPERACIÓN: enviando solicitud a $url');

      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({
          'email': correo,
        }),
      );

      print('RECUPERACIÓN: estado HTTP ${response.statusCode}');
      print('RECUPERACIÓN: respuesta ${response.body}');

      final responseData = _decodificarRespuesta(response);

      if (response.statusCode == 200) {
        // Algunos backends usan success y otros exito.
        if (responseData['success'] == false ||
            responseData['exito'] == false) {
          throw Exception(
            responseData['error'] ??
                responseData['message'] ??
                'El servidor no confirmó el envío del código.',
          );
        }

        return responseData;
      }

      throw Exception(
        responseData['error'] ??
            responseData['message'] ??
            'No se pudo enviar el código. '
                'Código HTTP: ${response.statusCode}.',
      );
    } catch (e) {
      throw Exception(_limpiarError(e));
    }
  }

  // Validar el código antes de permitir cambiar la contraseña.
  Future<Map<String, dynamic>> validarCodigo(
    String email,
    String codigo,
  ) async {
    final url = Uri.parse('${ApiConfig.authBaseUrl}/validate-code');

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({
          'email': email.trim(),
          'codigo': codigo.trim(),
        }),
      );

      final responseData = _decodificarRespuesta(response);

      if (response.statusCode == 200) {
        return responseData;
      }

      throw Exception(
        responseData['error'] ??
            responseData['message'] ??
            'Código inválido o expirado.',
      );
    } catch (e) {
      throw Exception(_limpiarError(e));
    }
  }

  // Verificar el código y cambiar la contraseña.
  Future<Map<String, dynamic>> verificarCodigo(
    String email,
    String codigo,
    String newPasswords,
  ) async {
    final url = Uri.parse('${ApiConfig.authBaseUrl}/verify-code');

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: jsonEncode({
          'email': email.trim(),
          'codigo': codigo.trim(),
          'newPasswords': newPasswords,
        }),
      );

      final responseData = _decodificarRespuesta(response);

      if (response.statusCode == 200) {
        return responseData;
      }

      throw Exception(
        responseData['error'] ??
            responseData['message'] ??
            'No se pudo cambiar la contraseña.',
      );
    } catch (e) {
      throw Exception(_limpiarError(e));
    }
  }

  // Convertir la respuesta del servidor a un mapa JSON.
  Map<String, dynamic> _decodificarRespuesta(
    http.Response response,
  ) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw Exception('El servidor devolvió una respuesta inesperada.');
    } on FormatException {
      throw Exception(
        'Respuesta no válida del servidor '
        '(HTTP ${response.statusCode}).',
      );
    }
  }

  // Evitar mostrar "Exception:" repetidamente.
  String _limpiarError(Object error) {
    return error.toString().replaceFirst(
          RegExp(r'^Exception:\s*'),
          '',
        );
  }
}
