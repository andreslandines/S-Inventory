import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class DispositivoFcmService {
  DispositivoFcmService._();

  static Future<bool> registrarToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final jwt = prefs.getString('jwt_token');

      if (jwt == null || jwt.isEmpty) {
        print('No hay sesión activa para registrar el dispositivo.');
        return false;
      }

      final url = Uri.parse(
        '${ApiConfig.baseUrl}/notificaciones/token',
      );

      final respuesta = await http.post(
        url,
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode({
          'token': token,
        }),
      );

      if (respuesta.statusCode == 200) {
        print('Dispositivo registrado para notificaciones.');
        return true;
      }

      print(
        'Error al registrar dispositivo: '
        '${respuesta.statusCode} ${respuesta.body}',
      );

      return false;
    } catch (e) {
      print('Error de conexión al registrar dispositivo: $e');
      return false;
    }
  }
}
