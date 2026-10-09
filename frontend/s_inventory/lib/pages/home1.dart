import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/core/estilostexto.dart';
import 'package:s_inventory/components/buscador_productos.dart';

class Home1 extends StatelessWidget {
  const Home1({super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
              width: 100,
              padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(10),
              child: BuscadorProductos(),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 
                  Row(
                    children: [
                      Expanded(
                        child: _tarjeta(
                          'Total de productos',
                          '248',
                          '+12 este mes',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _tarjeta(
                          'Ventas hoy',
                          '\$500MIL',
                          '+8.2%',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _tarjeta(
                          'Stock bajo',
                          '8',
                          'Requiere atención',
                          alerta: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _tarjeta(
                          'Por vencer',
                          '3',
                          'Próx. 7 días',
                          alerta: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Stock',
                    style: Estilotextos.textoSecundario,
                  ),

                  const SizedBox(height: 10),

                  _producto('Arroz Diana'),
                  _producto('Arroz Roa'),
                  _producto('Arroz integral'),

                  const SizedBox(height: 20),

                  const Text(
                    'Ventas - últimos 7 días',
                    style: Estilotextos.textoSecundario,
                  ),

                  const SizedBox(height: 10),

                  Container(
                    height: 140,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.fondoComponentes,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _barra('L', 35),
                        _barra('M', 55),
                        _barra('X', 50),
                        _barra('J', 80),
                        _barra('V', 20),
                        _barra('S', 55),
                        _barra('D', 35),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjeta(
    String titulo,
    String numero,
    String texto, {
    bool alerta = false,
  }) {
    return Container(
      height: 94,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.fondoComponentes,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: Estilotextos.textoPequeno,
          ),
          const SizedBox(height: 5),
          Text(
            numero,
            style: TextStyle(
              color: alerta ? Colors.orange : Colors.white,
              fontSize: 24,
              fontFamily: 'Roboto',
            ),
          ),
          Text(
            texto,
            style: TextStyle(
              color: alerta ? Colors.orange : AppColors.secondary,
              fontSize: 11,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }

  Widget _producto(String nombre) {
    return Container(
      height: 36,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.fondoComponenteSeleccionado,
        borderRadius: BorderRadius.circular(6),
        border: const Border(
          left: BorderSide(
            color: Colors.orange,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            nombre,
            style: Estilotextos.textoPequeno,
          ),
          const SizedBox(width: 15),
          const Text(
            '- Stock crítico',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 11,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }

  Widget _barra(String dia, double altura) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 35,
          height: altura,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          dia,
          style: Estilotextos.textoPequeno,
        ),
      ],
    );
  }
}