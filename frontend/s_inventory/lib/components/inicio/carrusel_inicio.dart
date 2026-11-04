
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';

class CarruselInicio extends StatefulWidget {
  const CarruselInicio({super.key});

  @override
  State<CarruselInicio> createState() => _CarruselInicioState();
}

class _CarruselInicioState extends State<CarruselInicio> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _pagina = 0;

  final List<Map<String, String>> _diapositivas = [
    {
      'titulo': 'Tu inventario,\nen buenas manos',
      'texto': 'Organiza tus productos y mantén el control.',
      'imagen':
          'assets/images/carrusel1.jpeg',
    },
    {
      'titulo': 'Controla cada\nmovimiento',
      'texto': 'Registra las ventas y actualiza tus existencias.',
      'imagen':
          'assets/images/carrusel2.jpeg',
    },
    {
      'titulo': 'Decide con\ninformación',
      'texto': 'Consulta tus reportes y conoce tu negocio.',
      'imagen':
          'assets/images/carrusel3.jpeg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_controller.hasClients) return;
      _pagina = (_pagina + 1) % _diapositivas.length;
      _controller.animateToPage(
        _pagina,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 205,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: PageView.builder(
              controller: _controller,
              itemCount: _diapositivas.length,
              onPageChanged: (pagina) =>
                  setState(() => _pagina = pagina),
              itemBuilder: (context, index) {
                final item = _diapositivas[index];

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      item['imagen']!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.fondoComponentes,
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.white24,
                          size: 80,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.fondo.withOpacity(0.90),
                            AppColors.fondo.withOpacity(0.50),
                            Colors.transparent,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(22),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: 0.78,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['titulo']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  height: 1.15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item['texto']!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_diapositivas.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _pagina == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _pagina == index
                    ? AppColors.accent
                    : Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }
}
