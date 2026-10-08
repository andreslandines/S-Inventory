import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final TabController controller;

  const BottomNavigation({
    super.key,
    required this.controller,
  });

  final List<IconData> iconos = const [
    Icons.home_rounded,
    Icons.inventory_2_rounded,
    Icons.auto_awesome_rounded,
    Icons.bar_chart_rounded,
    Icons.person_rounded,
  ];

  final List<String> titulos = const [
    'Inicio',
    'Inventario',
    'BoxIA',
    'Reportes',
    'Ajustes',
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return SafeArea(
          minimum: const EdgeInsets.fromLTRB(
            12,
            0,
            12,
            12,
          ),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: List.generate(
                iconos.length,
                (index) {
                  final seleccionado =
                      controller.index == index;

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        controller.animateTo(index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 200,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: seleccionado
                              ? Colors.white.withOpacity(0.12)
                              : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              iconos[index],
                              size: 21,
                              color: seleccionado
                                  ? Colors.white
                                  : Colors.white54,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              titulos[index],
                              style: TextStyle(
                                color: seleccionado
                                    ? Colors.white
                                    : Colors.white54,
                                fontSize: 10,
                                fontWeight: seleccionado
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
