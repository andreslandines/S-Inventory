import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/pages/splashcreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Ajustes extends StatefulWidget {
  const Ajustes({super.key});

  @override
  State<Ajustes> createState() => _AjustesState();
}
class _AjustesState extends State<Ajustes> {
  String _correo = '';

  @override
  void initState() {
    super.initState();
    _cargarUsuario(); 
  }

  Future<void> _cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _correo = prefs.getString('user_correo') ?? 'Correo no disponible';
    });
  }

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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary, // color de la segunda imagen
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 70),
                ),
                const SizedBox(height: 10),
                Text(
                  _correo, // correo automático
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Text('CUENTA', style: TextStyle(color: Colors.grey, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _opcionMenu(icon: Icons.person, texto: 'Editar perfil'),
          _opcionMenu(icon: Icons.lock, texto: 'Cambiar contraseña'),
          _opcionMenu(icon: Icons.cloud, texto: 'Notificaciones'),
          const SizedBox(height: 16),
          const Text('PREFERENCIAS', style: TextStyle(color: Colors.grey, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _opcionConToggle(icon: Icons.notifications, texto: 'Notificaciones', valorInicial: true),
          _opcionConToggle(icon: Icons.cloud, texto: 'Respaldo en la nube', valorInicial: true),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {

                          },
              style: ElevatedButton.styleFrom(
                elevation: 4,
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Cerrar sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _opcionMenu({required IconData icon, required String texto}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white),
      title: Text(texto, style: const TextStyle(color: Colors.white, fontSize: 21)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: () {},
    );
  }

  Widget _opcionConToggle({required IconData icon, required String texto, required bool valorInicial}) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: Colors.white),
      title: Text(texto, style: const TextStyle(color: Colors.white, fontSize: 21)),
      value: valorInicial,
      activeTrackColor: AppColors.primary,
      activeThumbColor: Colors.white,
      onChanged: (valor) {},
    );
  }
}