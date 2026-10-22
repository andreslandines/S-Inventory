
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:s_inventory/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> manejarMensajeEnSegundoPlano(
  RemoteMessage mensaje,
) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint(
    'Notificación recibida en segundo plano: ${mensaje.messageId}',
  );
}

class NotificacionService {
  NotificacionService._();

  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static bool _inicializado = false;

  static Future<String?> inicializar() async {
    // Este servicio solo se habilita en Android.
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      debugPrint(
        'Las notificaciones solo están habilitadas en Android.',
      );
      return null;
    }

    if (!_inicializado) {
      FirebaseMessaging.onBackgroundMessage(
        manejarMensajeEnSegundoPlano,
      );

      final permisos = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint(
        'Permisos de notificaciones: '
        '${permisos.authorizationStatus}',
      );

      if (permisos.authorizationStatus ==
          AuthorizationStatus.denied) {
        return null;
      }

      FirebaseMessaging.onMessage.listen((mensaje) {
        debugPrint(
          'Notificación recibida con la aplicación abierta.',
        );
        debugPrint('Título: ${mensaje.notification?.title}');
        debugPrint('Mensaje: ${mensaje.notification?.body}');
      });

      FirebaseMessaging.onMessageOpenedApp.listen((mensaje) {
        debugPrint('El usuario abrió una notificación push.');
      });

      final mensajeInicial =
          await _messaging.getInitialMessage();

      if (mensajeInicial != null) {
        debugPrint(
          'La aplicación se abrió desde una notificación.',
        );
      }

      _inicializado = true;
    }

    return _messaging.getToken();
  }
}
