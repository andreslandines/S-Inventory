import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'producto_widgets.dart';

class ProductoCampoTexto extends StatelessWidget {
  final TextEditingController controller;
  final String etiqueta;
  final IconData icono;
  final String? Function(String?)? validator;
  final TextInputType? teclado;
  final int maxLineas;

  const ProductoCampoTexto({
    super.key,
    required this.controller,
    required this.etiqueta,
    required this.icono,
    this.validator,
    this.teclado,
    this.maxLineas = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      keyboardType: teclado,
      maxLines: maxLineas,
      validator: validator,
      decoration: ProductoEstilos.campo(etiqueta, icono),
    );
  }
}

class ProductoCampoSelector extends StatelessWidget {
  final String etiqueta;
  final IconData icono;
  final String? valor;
  final List<String> opciones;
  final ValueChanged<String?>? onChanged;
  final String? Function(String?)? validator;

  const ProductoCampoSelector({
    super.key,
    required this.etiqueta,
    required this.icono,
    required this.valor,
    required this.opciones,
    required this.onChanged,
    this.validator,
  });

  Future<String?> _abrirSelector(
    BuildContext context,
    String? valorActual,
  ) async {
    return await showDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 35,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.of(dialogContext).size.height * 0.65,
              maxWidth: 420,
            ),
            decoration: BoxDecoration(
              color: const Color(0xE8111F35),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.30),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Encabezado
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    16,
                    12,
                    12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: productoAmarillo.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(
                          icono,
                          color: productoAmarillo,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seleccionar $etiqueta',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${opciones.length} opciones disponibles',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Cerrar',
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white70,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(
                  height: 1,
                  color: Colors.white.withOpacity(0.10),
                ),

                // Opciones disponibles
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: opciones.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final opcion = opciones[index];
                      final seleccionada =
                          opcion == valorActual;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.pop(dialogContext, opcion);
                          },
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 13,
                            ),
                            decoration: BoxDecoration(
                              color: seleccionada
                                  ? productoAzul.withOpacity(0.22)
                                  : Colors.white.withOpacity(0.035),
                              borderRadius:
                                  BorderRadius.circular(12),
                              border: Border.all(
                                color: seleccionada
                                    ? productoAmarillo
                                        .withOpacity(0.65)
                                    : Colors.white
                                        .withOpacity(0.07),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    opcion,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: seleccionada
                                          ? productoAmarillo
                                          : Colors.white,
                                      fontSize: 13,
                                      fontWeight: seleccionada
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (seleccionada)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: productoAmarillo,
                                    size: 19,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: valor,
      validator: validator,
      builder: (field) {
        final seleccionValida =
            field.value != null &&
            opciones.contains(field.value);

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final seleccion = await _abrirSelector(
              context,
              field.value,
            );

            if (seleccion != null) {
              field.didChange(seleccion);
              onChanged?.call(seleccion);
            }
          },
          child: InputDecorator(
            isEmpty: !seleccionValida,
            decoration: ProductoEstilos.campo(
              etiqueta,
              icono,
            ).copyWith(
              errorText: field.errorText,
              suffixIcon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: productoAmarillo,
              ),
            ),
            // La etiqueta se dibuja desde InputDecoration.
            // No repetirla dentro del contenido del selector.
            child: Text(
              seleccionValida ? field.value! : '',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }
}
