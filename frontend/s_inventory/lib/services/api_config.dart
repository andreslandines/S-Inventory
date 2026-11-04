import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Utilizar el backend desplegado en Render.
  static const bool useRemote = true;

  // Backend de producción.
  static const String _remoteUrl =
      'https://s-inventory.onrender.com';

  // Servidor local para futuras pruebas.
  static const String _localUrl =
      'http://192.168.1.172:3000';

  static String get baseUrl {
    if (useRemote) {
      return _remoteUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    if (Platform.isAndroid || Platform.isIOS) {
      return _localUrl;
    }

    return _localUrl;
  }

  static String get authUrl => '$baseUrl/auth';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
} 