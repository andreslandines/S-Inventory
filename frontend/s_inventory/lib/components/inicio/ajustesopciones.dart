import 'package:flutter/material.dart';
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Recoverypassword(desdeAjustes: true),
            ),
          );
        },
      ),
    );
  }
}
