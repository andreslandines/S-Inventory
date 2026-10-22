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

  static Future<String?> inicializar({
    required String vapidKey,
  }) async {
    if (_inicializado) {
      return _obtenerToken(vapidKey);
    }

    if (kIsWeb &&
        (vapidKey.trim().isEmpty ||
            vapidKey.startsWith('PEGA_'))) {
      throw StateError(
        'Configura la clave pública VAPID de Firebase.',
      );
    }

    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(
        manejarMensajeEnSegundoPlano,
      );
    }

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

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage mensaje) {
        debugPrint(
          'Notificación recibida con la aplicación abierta.',
        );
        debugPrint(
          'Título: ${mensaje.notification?.title}',
        );
        debugPrint(
          'Mensaje: ${mensaje.notification?.body}',
        );
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage mensaje) {
        debugPrint(
          'El usuario abrió una notificación push.',
        );
      },
    );

    final mensajeInicial =
        await _messaging.getInitialMessage();

    if (mensajeInicial != null) {
      debugPrint(
        'La aplicación se abrió desde una notificación.',
      );
    }

    _inicializado = true;

    return _obtenerToken(vapidKey);
  }

  static Future<String?> _obtenerToken(
    String vapidKey,
  ) async {
    final token = await _messaging.getToken(
      vapidKey: kIsWeb ? vapidKey : null,
    );

    if (token != null) {
      debugPrint('Token FCM obtenido correctamente.');
    } else {
      debugPrint('No se pudo obtener el token FCM.');
    }

    return token;
  }
}