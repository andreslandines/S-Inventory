
import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/core/estilostexto.dart';
import 'package:s_inventory/components/inicio/ajustesopciones.dart';
import 'package:s_inventory/components/inicio/login.dart';
import 'package:s_inventory/pages/manual_usuario_screen.dart';
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
      _correo = prefs.getString('user_correo') ??
          'Correo no disponible';
    });
  }

  Future<void> _cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('user_correo');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  // Abrir manual PDF
  void _abrirManual() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManualUsuarioScreen(),
      ),
    );
  }

  // Mostrar información de desarrolladores
  void _mostrarDesarrolladores() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F2937),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Column(
            children: [
              Icon(
                Icons.code_rounded,
                color: Color(0xFFFFC400),
                size: 38,
              ),
              SizedBox(height: 10),
              Text(
                'Desarrolladores',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DesarrolladorItem(
                nombre: 'Dana Sofía Montoya Tovar',
                numero: '01',
              ),
              SizedBox(height: 15),
              _DesarrolladorItem(
                nombre: 'Andrés Felipe Landines Cardoso',
                numero: '02',
              ),
              SizedBox(height: 22),
              Divider(color: Colors.white12),
              SizedBox(height: 10),
              Text(
                'S-Inventory',
                style: TextStyle(
                  color: Color(0xFFFFC400),
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Sistema de Gestión de Inventario',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'SENA · 2026',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cerrar',
                style: TextStyle(
                  color: Color(0xFFFFC400),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Opciones adicionales de información
  Widget _opcionInformacion({
    required IconData icono,
    required String titulo,
    required String descripcion,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 4,
        ),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFFC400).withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icono,
            color: const Color(0xFFFFC400),
          ),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          descripcion,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white38,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        margin: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 20,
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 164, 161, 161)
              .withOpacity(0.06),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white12, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.02),
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
                children: [
                  const SizedBox(height: 30),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.white24,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.fondo,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _correo,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'CUENTA',
              style: Estilotextos.textoNormal,
            ),
            const SizedBox(height: 8),

            const OpcionMenu1(),
            const OpcionMenu2(),
            const OpcionMenu3(),

            const SizedBox(height: 12),

            const Text(
              'PREFERENCIAS',
              style: Estilotextos.textoNormal,
            ),
            const SizedBox(height: 8),

            const OpcionConToggle1(),

            const SizedBox(height: 20),

            const Text(
              'INFORMACIÓN',
              style: Estilotextos.textoNormal,
            ),
            const SizedBox(height: 10),

            _opcionInformacion(
              icono: Icons.menu_book_rounded,
              titulo: 'Manual de usuario',
              descripcion: 'Consulta la guía de S-Inventory',
              onTap: _abrirManual,
            ),

            _opcionInformacion(
              icono: Icons.groups_rounded,
              titulo: 'Desarrolladores',
              descripcion: 'Conoce al equipo de desarrollo',
              onTap: _mostrarDesarrolladores,
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: _cerrarSesion,
                style: ElevatedButton.styleFrom(
                  elevation: 4,
                  backgroundColor:
                      const Color.fromARGB(255, 245, 0, 0)
                          .withOpacity(0.46),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Cerrar sesión',
                  style: Estilotextos.textoBoton,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Componente para cada desarrollador
class _DesarrolladorItem extends StatelessWidget {
  final String nombre;
  final String numero;

  const _DesarrolladorItem({
    required this.nombre,
    required this.numero,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFFFC400).withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            numero,
            style: const TextStyle(
              color: Color(0xFFFFC400),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            nombre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
