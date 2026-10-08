import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:s_inventory/core/colores.dart';

class EditarPerfil extends StatefulWidget {
  const EditarPerfil({super.key});

  @override
  State<EditarPerfil> createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController? _nombreController;
  TextEditingController? _correoController;
  TextEditingController? _telefonoController;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _nombreController = TextEditingController(
        text: prefs.getString('user_name') ?? '',
      );

      _correoController = TextEditingController(
        text: prefs.getString('user_email') ?? '',
      );

      _telefonoController = TextEditingController(
        text: prefs.getString('user_phone') ?? '',
      );
    });
  }

  @override
  void dispose() {
    _nombreController?.dispose();
    _correoController?.dispose();
    _telefonoController?.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'user_name',
      _nombreController!.text.trim(),
    );

    await prefs.setString(
      'user_email',
      _correoController!.text.trim(),
    );

    await prefs.setString(
      'user_phone',
      _telefonoController!.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil actualizado correctamente'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_nombreController == null ||
        _correoController == null ||
        _telefonoController == null) {
      return Scaffold(
        backgroundColor: AppColors.fondo,
        body: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: AppColors.fondo,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Editar perfil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),

              const CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white12,
                child: Icon(
                  Icons.person_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              TextButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.camera_alt_outlined,
                ),
                label: const Text('Cambiar foto'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 25),

              _campo(
                controller: _nombreController!,
                label: 'Nombre',
                icono: Icons.person_outline_rounded,
              ),

              const SizedBox(height: 16),

              _campo(
                controller: _correoController!,
                label: 'Correo electrónico',
                icono: Icons.email_outlined,
                teclado: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              _campo(
                controller: _telefonoController!,
                label: 'Teléfono',
                icono: Icons.phone_outlined,
                teclado: TextInputType.phone,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _guardarCambios,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Guardar cambios'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.fondo,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    TextInputType? teclado,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: teclado,
      style: const TextStyle(
        color: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Este campo es obligatorio';
        }

        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white60,
        ),
        prefixIcon: Icon(
          icono,
          color: Colors.white70,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.10),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.white,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}