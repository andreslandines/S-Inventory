
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/pages/notificaciones.dart';
import 'package:s_inventory/pages/perfil.dart';
import 'package:s_inventory/pages/recoverycodes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:s_inventory/services/notificacion_service.dart';

class OpcionMenu1 extends StatelessWidget {
  const OpcionMenu1({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(
          Icons.person,
          color: Colors.white,
          size: 20,
        ),
        title: const Text(
          'Editar perfil',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.white54,
          size: 23,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Perfil(),
            ),
          );
        },
      ),
    );
  }
}

class OpcionMenu2 extends StatelessWidget {
  const OpcionMenu2({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(
          Icons.lock,
          color: Colors.white,
          size: 20,
        ),
        title: const Text(
          'Cambiar contraseña',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.white54,
          size: 23,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const Recoverypassword(desdeAjustes: true),
            ),
          );
        },
      ),
    );
  }
}

class OpcionMenu3 extends StatelessWidget {
  const OpcionMenu3({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(
          Icons.notifications_active,
          color: Colors.white,
          size: 20,
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.white54,
          size: 23,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const NotificacionesPage(),
            ),
          );
        },
      ),
    );
  }
}

class OpcionConToggle1 extends StatefulWidget {
  const OpcionConToggle1({super.key});

  @override
  State<OpcionConToggle1> createState() =>
      _OpcionConToggle1State();
}

class _OpcionConToggle1State extends State<OpcionConToggle1> {
  bool _activado = false;
  bool _procesando = true;

  @override
  void initState() {
    super.initState();
    _cargarPreferencia();
  }

  Future<void> _cargarPreferencia() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        _activado =
            prefs.getBool('notificaciones_activadas') ?? false;
        _procesando = false;
      });
    } catch (error) {
      debugPrint('Error al cargar preferencias: $error');

      if (mounted) {
        setState(() => _procesando = false);
      }
    }
  }

  Future<void> _cambiarNotificaciones(bool valor) async {
    if (_procesando) return;

    if (kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android) {
      _mostrarMensaje(
        'Las notificaciones solo están disponibles en Android.',
      );
      return;
    }

    setState(() => _procesando = true);

    try {
      if (valor) {
        final token = await NotificacionService.inicializar();

        if (token == null || token.isEmpty) {
          _mostrarMensaje(
            'No se obtuvo el token de Firebase. '
            'Revisa los permisos y la configuración de Android.',
          );
          return;
        }

        // No mostramos ni guardamos el token en la interfaz.
        debugPrint('Token FCM obtenido correctamente.');
      } else {
        await FirebaseMessaging.instance.deleteToken();
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notificaciones_activadas', valor);

      if (!mounted) return;

      setState(() => _activado = valor);

      _mostrarMensaje(
        valor
            ? 'Notificaciones activadas en Android.'
            : 'Notificaciones desactivadas.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'ERROR AL CAMBIAR NOTIFICACIONES: $error',
      );
      debugPrintStack(stackTrace: stackTrace);

      _mostrarMensaje(
        'No se pudo configurar Firebase. '
        'Revisa la terminal para ver el error.',
      );
    } finally {
      if (mounted) {
        setState(() => _procesando = false);
      }
    }
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: const Icon(
          Icons.notifications,
          color: Colors.white,
          size: 20,
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        subtitle: _procesando
            ? const Text(
                'Actualizando...',
                style: TextStyle(color: Colors.white54),
              )
            : null,
        value: _activado,
        activeTrackColor: AppColors.fondo,
        activeThumbColor: Colors.white,
        onChanged:
            _procesando ? null : _cambiarNotificaciones,
      ),
    );
  }
}
