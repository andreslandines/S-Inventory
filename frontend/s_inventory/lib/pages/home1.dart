
import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/components/buscador_productos.dart';
import 'package:s_inventory/components/inicio/carrusel_inicio.dart';
import 'package:s_inventory/components/inicio/accesos_rapidos.dart';
import 'package:s_inventory/pages/registrar_ventas.dart';

class Home1 extends StatelessWidget {
  final VoidCallback onAgregarProducto;
  final VoidCallback onReportes;

  const Home1({
    super.key,
    required this.onAgregarProducto,
    required this.onReportes,
  });

  Future<void> _abrirVenta(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegistrarVenta(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.fondo,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            '¡Hola, administrador!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Controla tu inventario y mantén tu negocio en orden.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 22),
          const BuscadorProductos(),
          const SizedBox(height: 24),
          const CarruselInicio(),
          const SizedBox(height: 28),
          const Text(
            'Accesos rápidos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          AccesosRapidos(
            onVenta: () => _abrirVenta(context),
            onAgregarProducto: onAgregarProducto,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 164, 161, 161).withOpacity(0.06),
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
            child: const Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.accent,
                  size: 30,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Un consejo para ti',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Mantén las existencias actualizadas para '
                        'evitar faltantes y controlar mejor tu negocio.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
