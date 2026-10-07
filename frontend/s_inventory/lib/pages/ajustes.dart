import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';

class Ajustes extends StatefulWidget {
  const Ajustes({super.key});

  @override
  State<Ajustes> createState() => _AjustesState();
}

class _AjustesState extends State<Ajustes> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.fondo,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white12, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,   // ← hace que el Container solo ocupe lo necesario
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección: CUENTA
          const Text('CUENTA', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _opcionMenu(icon: Icons.person, texto: 'Editar perfil'),
          _opcionMenu(icon: Icons.lock, texto: 'Cambiar contraseña'),
          _opcionMenu(icon: Icons.cloud, texto: 'Notificaciones'),
          const SizedBox(height: 16),
          // Sección: PREFERENCIAS
          const Text('PREFERENCIAS', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _opcionConToggle(icon: Icons.notifications, texto: 'Notificaciones', valorInicial: true),
          _opcionConToggle(icon: Icons.cloud, texto: 'Respaldo en la nube', valorInicial: true),
          const SizedBox(height: 24),
          // Botón Cerrar sesión
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para las opciones de menú (con flecha >
  Widget _opcionMenu({required IconData icon, required String texto}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white),
      title: Text(texto, style: const TextStyle(color: Colors.white, fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: () {},
    );
  }

  // Widget para las opciones con toggle
  Widget _opcionConToggle({required IconData icon, required String texto, required bool valorInicial}) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: Colors.white),
      title: Text(texto, style: const TextStyle(color: Colors.white, fontSize: 16)),
      value: valorInicial,
      onChanged: (valor) {},
    );
  }
}