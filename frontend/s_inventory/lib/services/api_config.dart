import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;


class ApiConfig{
  static String get baseUrl{
    if (kIsWeb) {
      return 'http://localhost:3000/auth';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/auth';

    } else if (Platform.isIOS) {
      return 'http://localhost:3000/auth';
    }  
      return 'http://localhost:3000/auth';
    }

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}