import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/pages/perfil.dart';
import 'package:s_inventory/pages/recoverycodes.dart';

// ===== Menú 1 =====
class OpcionMenu1 extends StatelessWidget {
  final VoidCallback? onTap;
  const OpcionMenu1({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.person, color: Colors.white, size: 22),
        title: const Text('Editar perfil', style: TextStyle(color: Colors.white, fontSize: 18)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54, size: 23),
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

// ===== Menú 2 =====
class OpcionMenu2 extends StatelessWidget {
  final VoidCallback? onTap;
  const OpcionMenu2({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.lock, color: Colors.white, size: 22),
        title: const Text('Cambiar contraseña', style: TextStyle(color: Colors.white, fontSize: 18)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54, size: 23),
        onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Recoverypassword()),
                );
              },
      ),
    );
  }
}

// ===== Menú 3 =====
class OpcionMenu3 extends StatelessWidget {
  final VoidCallback? onTap;
  const OpcionMenu3({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.cloud, color: Colors.white, size: 22),
        title: const Text('Notificaciones', style: TextStyle(color: Colors.white, fontSize: 18)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54, size: 23),
        onTap: () {},
      ),
    );
  }
}

// ===== Toggle 1 =====
class OpcionConToggle1 extends StatelessWidget {
  final ValueChanged<bool>? onChanged;
  const OpcionConToggle1({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: const Icon(Icons.notifications, color: Colors.white, size: 22),
        title: const Text('Notificaciones', style: TextStyle(color: Colors.white, fontSize: 18)),
        value: true,
        activeTrackColor: AppColors.primary,
        activeThumbColor: Colors.white,
        onChanged: onChanged,
      ),
    );
  }
}

// ===== Toggle 2 =====
class OpcionConToggle2 extends StatelessWidget {
  final ValueChanged<bool>? onChanged;
  const OpcionConToggle2({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: const Icon(Icons.cloud, color: Colors.white, size: 22),
        title: const Text('Respaldo en la nube', style: TextStyle(color: Colors.white, fontSize: 18)),
        value: true,
        activeTrackColor: AppColors.primary,
        activeThumbColor: Colors.white,
        onChanged: onChanged,
      ),
    );
  }
}