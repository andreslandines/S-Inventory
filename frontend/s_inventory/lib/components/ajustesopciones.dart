import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/pages/perfil.dart';
import 'package:s_inventory/pages/recoverycodes.dart';

class OpcionMenu1 extends StatelessWidget {
  const OpcionMenu1({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.person, color: Colors.white, size: 20),
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
            MaterialPageRoute(builder: (context) => const Perfil()),
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
        leading: const Icon(Icons.lock, color: Colors.white, size: 20),
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
          Navigator.push(context,
            MaterialPageRoute( builder: (context) => const Recoverypassword(desdeAjustes: true),
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
        onTap: () {},
      ),
    );
  }
}

class OpcionConToggle1 extends StatefulWidget {
  const OpcionConToggle1({super.key});

  @override
  State<OpcionConToggle1> createState() => _OpcionConToggle1State();
}

class _OpcionConToggle1State extends State<OpcionConToggle1> {
  bool _activado = true;

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
        value: _activado,
        activeTrackColor: AppColors.fondo,
        activeThumbColor: Colors.white,
        onChanged: (valor) {
          setState(() {
            _activado = valor;
          });
        },
      ),
    );
  }
}

class OpcionConToggle2 extends StatefulWidget {
  const OpcionConToggle2({super.key});

  @override
  State<OpcionConToggle2> createState() => _OpcionConToggle2State();
}

class _OpcionConToggle2State extends State<OpcionConToggle2> {
  bool _activado = true;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: const Icon(
          Icons.cloud,
          color: Colors.white,
          size: 20,
        ),
        title: const Text(
          'Respaldo en la nube',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        value: _activado,
        activeTrackColor: AppColors.fondo,
        activeThumbColor: Colors.white,
        onChanged: (valor) {
          setState(() {
            _activado = valor;
          });
        },
      ),
    );
  }
}
