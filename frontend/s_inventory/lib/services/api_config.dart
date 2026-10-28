import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static const bool useRemote = true;

  // URL del backend desplegado en Render.
  static const String _remoteUrl =
      'https://s-inventory.onrender.com';

  static String get baseUrl {
    if (useRemote) {
      return _remoteUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }

    if (Platform.isIOS) {
      return 'http://localhost:3000';
    }

    return 'http://localhost:3000';
  }

  static String get authUrl => '$baseUrl/auth';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}