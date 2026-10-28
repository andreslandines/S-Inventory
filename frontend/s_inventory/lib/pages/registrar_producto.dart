
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:s_inventory/components/producto/formulario.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/services/producto_service.dart';

class RegistrarProductoPage extends StatefulWidget {
  const RegistrarProductoPage({super.key});

  @override
  State<RegistrarProductoPage> createState() =>
      _RegistrarProductoPageState();
}

class _RegistrarProductoPageState extends State<RegistrarProductoPage> {
  final ProductoService _service = ProductoService();
  bool _abriendoFormulario = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _abrirFormulario();
    });
  }

  Future<void> _abrirFormulario() async {
    if (_abriendoFormulario || _guardando || !mounted) return;

    setState(() => _abriendoFormulario = true);

    try {
      final datos = await FormularioProducto.mostrar(context);

      if (!mounted || datos == null) {
        if (mounted) {
          Navigator.pop(context, false);
        }
        return;
      }

      setState(() => _guardando = true);

      final XFile? imagen = datos['imagen'] as XFile?;
      final String? imagenUrl = datos['imagenUrl'] as String?;

      List<int>? bytes;
      if (imagen != null) {
        bytes = await imagen.readAsBytes();
      }

      await _service.crearProducto(
        nombre: datos['nombre'] as String,
        descripcion: datos['descripcion'] as String,
        precio: datos['precio'] as String,
        categoria: datos['categoria'] as String,
        stock: datos['stock'] as String,
        imagenBytes: bytes,
        nombreImagen: imagen?.name,
        imagenUrl: imagenUrl,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto registrado correctamente.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, false);
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
          _abriendoFormulario = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        title: const Text('Registrar producto'),
        backgroundColor: AppColors.fondo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_guardando)
                const CircularProgressIndicator(
                  color: AppColors.accent,
                )
              else
                const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.accent,
                  size: 52,
                ),
              const SizedBox(height: 16),
              Text(
                _guardando
                    ? 'Guardando producto...'
                    : 'Preparando formulario...',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              if (!_guardando && !_abriendoFormulario) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _abrirFormulario,
                  child: const Text('Abrir formulario'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
