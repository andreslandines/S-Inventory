import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:s_inventory/components/scanner/barcode_scanner_field.dart';
import 'package:s_inventory/core/colores.dart';

import 'producto_widgets.dart';
import 'producto_campos.dart';
import 'producto_imagen.dart';

class FormularioProducto {
  static const Map<String, List<String>> categorias = {
    'Frutas, verduras y tubérculos': [
      'Papa',
      'Papa amarilla',
      'Cebolla cabezona',
      'Cebolla larga',
      'Tomate',
      'Zanahoria',
      'Ajo',
      'Otro',
    ],
    'Abarrotes y despensa': [
      'Arroz',
      'Pasta',
      'Macarrones',
      'Maíz en bolsa',
      'Avena',
      'Café',
      'Chocolate',
      'Panela',
      'Sal',
      'Azúcar',
      'Aceite',
      'Manteca',
      'Maicena',
      'Levadura',
      'Polvo para hornear',
      'Otro',
    ],
    'Enlatados y conservas': [
      'Sardinas en lata',
      'Atún en lata',
      'Salchichas en lata',
      'Maíz en lata',
      'Otro',
    ],
    'Lácteos y derivados': [
      'Crema de leche',
      'Mantequilla',
      'Leche condensada',
      'Leche',
      'Otro',
    ],
    'Bebidas': [
      'Gaseosas',
      'Electrolitos',
      'Frutiño',
      'Avena en bolsa',
      'Vaso de guarapo',
      'Otro',
    ],
    'Helados y congelados': [
      'Bolis',
      'Bonais',
      'Hielo en bolsa',
      'Otro',
    ],
    'Panadería y comidas preparadas': [
      'Pan',
      'Empanadas',
      'Chocorramo',
      'Otro',
    ],
    'Dulces, galletas y snacks': [
      'Galletas',
      'Gomitas',
      'Chicles',
      'Chupetes',
      'Dulces',
      'Chocolatinas',
      'Papas de paquete',
      'Otro',
    ],
    'Salsas y condimentos': [
      'Salsas',
      'Sazonador',
      'Color',
      'Canela',
      'Pimienta',
      'Ajo en polvo',
      'Maggi',
      'Ricostilla',
      'Otro',
    ],
    'Aseo y limpieza': [
      'Detergente',
      'Suavizante',
      'Jabón para ropa',
      'Lavaloza',
      'Sabra',
      'Brilladora',
      'Esponjas',
      'Bicarbonato',
      'Desinfectante',
      'Cloro',
      'Otro',
    ],
    'Cuidado personal y belleza': [
      'Shampoo',
      'Acondicionador',
      'Crema para el cabello',
      'Gel para el cabello',
      'Desodorante',
      'Perfume para hombre',
      'Perfume para mujer',
      'Bloqueador solar',
      'Peines para hombre',
      'Peines para mujer',
      'Cepillos',
      'Cuchillas de afeitar',
      'Otro',
    ],
    'Higiene femenina': [
      'Toallas íntimas',
      'Tampones',
      'Otro',
    ],
    'Bebés y maternidad': [
      'Pañales',
      'Pañitos húmedos',
      'Chupetes para tetero',
      'Colcha para bebé',
      'Otro',
    ],
    'Ropa y calzado': [
      'Ropa para hombre',
      'Ropa para mujer',
      'Ropa para niños',
      'Ropa para niñas',
      'Zapatos para hombre',
      'Zapatos para mujer',
      'Zapatos para niños',
      'Zapatos para niñas',
      'Otro',
    ],
    'Accesorios y bisutería': [
      'Gomas para el cabello',
      'Cauchitos',
      'Caimanes para mujer',
      'Pinzas para el cabello',
      'Balacas',
      'Rubor',
      'Otro',
    ],
    'Papelería y útiles escolares': [
      'Cuadernos',
      'Cartulina',
      'Cartulina en pliego',
      'Bolígrafos',
      'Lápices',
      'Marcadores',
      'Reglas',
      'Borradores',
      'Sacapuntas',
      'Correctores',
      'Sobres',
      'Bisturí',
      'Cinta',
      'Otro',
    ],
    'Manualidades y costura': [
      'Escarcha',
      'Colbón',
      'Temperas',
      'Plastilina',
      'Crayones',
      'Hilos de coser',
      'Papel seda',
      'Papel crepé',
      'Foami',
      'Velas volcán',
      'Otro',
    ],
    'Ferretería y plomería': [
      'Llaves para el agua',
      'Cinta de teflón',
      'Tubos para agua',
      'Chazos',
      'Tornillos',
      'Otro',
    ],
    'Electricidad e iluminación': [
      'Bombillos',
      'Pilas',
      'Cinta aislante',
      'Otro',
    ],
    'Droguería y primeros auxilios': [
      'Alcohol antiséptico',
      'Curitas',
      'Tapabocas',
      'Medicamentos de venta libre',
      'Otro',
    ],
    'Cigarrillos y encendedores': [
      'Cigarrillos',
      'Mecheras',
      'Otro',
    ],
    'Hogar, desechables y empaques': [
      'Bolsas plásticas',
      'Bolsas de regalo',
      'Vasos desechables',
      'Servilletas',
      'Palillos',
      'Papel aluminio',
      'Plásticos',
      'Otro',
    ],
    'Mascotas': [
      'Purina para perros',
      'Purina para gatos',
      'Otro',
    ],
    'Velas y artículos para fiestas': [
      'Velas',
      'Velas volcán',
      'Sobres',
      'Otro',
    ],
    'Otros': [
      'Otro',
    ],
  };

  static Future<Map<String, dynamic>?> mostrar(
    BuildContext context, {
    Map<String, dynamic>? producto,
  }) async {
    final bool editando = producto != null;

    final formKey = GlobalKey<FormState>();

    final nombre = TextEditingController(
      text: producto?['nombre']?.toString() ?? '',
    );

    final descripcion = TextEditingController(
      text: producto?['descripcion']?.toString() ?? '',
    );

    final precio = TextEditingController(
      text: ProductoCampoTexto.formatearPrecio(
        producto?['precio'],
      ),
    );

    final stock = TextEditingController(
      text: producto?['stock']?.toString() ?? '0',
    );

    final costoCaja = TextEditingController();
    final unidadesCaja = TextEditingController();
    final porcentajeGanancia = TextEditingController(
      text: '30',
    );

    double? costoUnitarioCalculado;
    double? precioSugeridoCalculado;
    double? gananciaCalculada;

    final url = TextEditingController();
    final otroTipo = TextEditingController();

    final codigoBarras = TextEditingController(
      text: producto?['codigo_barras']?.toString() ?? '',
    );

    final imagenExistente =
        producto?['imagen']?.toString() ?? '';

    XFile? imagen;

    final partesCategoria =
        (producto?['categoria']?.toString() ?? '').split(' - ');

    String? categoria;

    if (editando &&
        categorias.containsKey(partesCategoria.first.trim())) {
      categoria = partesCategoria.first.trim();
    }

    final tipoOriginal = partesCategoria.length > 1
        ? partesCategoria.sublist(1).join(' - ').trim()
        : '';

    String? tipo;

    // Fecha de vencimiento opcional del primer lote.
    DateTime? fechaVencimiento;

    if (categoria != null && tipoOriginal.isNotEmpty) {
      final opciones = categorias[categoria] ?? [];

      if (opciones.contains(tipoOriginal)) {
        tipo = tipoOriginal;
      } else {
        tipo = 'Otro';
        otroTipo.text = tipoOriginal;
      }
    }

    bool usarUrl = false;

    String? requerido(String? valor) {
      if (valor == null || valor.trim().isEmpty) {
        return 'Este campo es obligatorio';
      }

      return null;
    }

    void calcularPrecioSugerido(
      void Function(void Function()) actualizar,
    ) {
      final costo = double.tryParse(
        costoCaja.text
            .replaceAll('.', '')
            .replaceAll(',', '.')
            .trim(),
      );

      final unidades = int.tryParse(
        unidadesCaja.text.trim(),
      );

      final porcentaje = double.tryParse(
        porcentajeGanancia.text.replaceAll(',', '.').trim(),
      );

      if (costo == null ||
          costo <= 0 ||
          unidades == null ||
          unidades <= 0 ||
          porcentaje == null ||
          porcentaje < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Verifica el costo de la caja, las unidades y el porcentaje de ganancia.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final costoUnitario = costo / unidades;
      final precioSugerido =
          (costoUnitario * (1 + porcentaje / 100)).roundToDouble();

      actualizar(() {
        costoUnitarioCalculado = costoUnitario;
        precioSugeridoCalculado = precioSugerido;
        gananciaCalculada =
            precioSugerido - costoUnitario;
      });
    }

    try {
      return await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, actualizar) {
            Future<void> elegirImagen(ImageSource source) async {
              try {
                final archivo = await ImagePicker().pickImage(
                  source: source,
                  imageQuality: 80,
                  maxWidth: 1200,
                );

                if (archivo != null) {
                  actualizar(() {
                    imagen = archivo;
                    usarUrl = false;
                    url.clear();
                  });
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'No se pudo seleccionar la imagen.',
                      ),
                    ),
                  );
                }
              }
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 22,
              ),
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 520,
                ),
                decoration: BoxDecoration(
                  color: AppColors.fondo,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: productoAzul.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _encabezado(
                      dialogContext,
                      editando: editando,
                    ),
                    Container(
                      height: 1,
                      color: Colors.white10,
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          4,
                          20,
                          20,
                        ),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const ProductoSeccion(
                                titulo: 'Imagen del producto',
                                icono: Icons.photo_camera_outlined,
                              ),
                              ProductoSelectorImagen(
                                imagen: imagen,
                                usarUrl: usarUrl,
                                url: url.text,
                                imagenExistente: imagenExistente,
                                permitirCambiarModo: !editando,
                                elegirGaleria: () =>
                                    elegirImagen(ImageSource.gallery),
                                elegirCamara: () =>
                                    elegirImagen(ImageSource.camera),
                                cambiarModo: () => actualizar(() {
                                  usarUrl = !usarUrl;
                                  imagen = null;
                                  url.clear();
                                }),
                              ),
                              if (usarUrl) ...[
                                const SizedBox(height: 12),
                                ProductoCampoTexto(
                                  controller: url,
                                  etiqueta: 'URL de la imagen *',
                                  icono: Icons.link,
                                  validator: (valor) {
                                    final uri = Uri.tryParse(
                                      valor?.trim() ?? '',
                                    );

                                    if (uri == null ||
                                        !uri.hasAuthority ||
                                        !['http', 'https'].contains(
                                          uri.scheme,
                                        )) {
                                      return 'Ingresa una URL válida';
                                    }

                                    return null;
                                  },
                                ),
                              ],
                              const ProductoSeccion(
                                titulo: 'Información básica',
                                icono: Icons.edit_note_rounded,
                              ),
                              ProductoCampoTexto(
                                controller: nombre,
                                etiqueta: 'Nombre del producto *',
                                icono: Icons.inventory_2_outlined,
                                validator: requerido,
                              ),
                              const SizedBox(height: 12),
                              ProductoCampoTexto(
                                controller: descripcion,
                                etiqueta: 'Descripción',
                                icono: Icons.notes_rounded,
                                maxLineas: 2,
                              ),
                              const SizedBox(height: 12),
                              BarcodeScannerField(
                                controller: codigoBarras,
                                label: 'Código de barras',
                                hint: 'Escanea o escribe el código',
                              ),
                              const ProductoSeccion(
                                titulo: 'Categoría y tipo',
                                icono: Icons.category_outlined,
                              ),
                              ProductoCampoSelector(
                                etiqueta: 'Categoría *',
                                icono: Icons.grid_view_rounded,
                                valor: categoria,
                                opciones: categorias.keys.toList(),
                                validator: (v) => v == null
                                    ? 'Selecciona una categoría'
                                    : null,
                                onChanged: (v) => actualizar(() {
                                  categoria = v;
                                  tipo = null;
                                  otroTipo.clear();
                                }),
                              ),
                              const SizedBox(height: 12),
                              ProductoCampoSelector(
                                etiqueta: 'Tipo de producto *',
                                icono: Icons.sell_outlined,
                                valor: tipo,
                                opciones: categorias[categoria] ?? [],
                                validator: (v) => v == null
                                    ? 'Selecciona un tipo'
                                    : null,
                                onChanged: categoria == null
                                    ? null
                                    : (v) => actualizar(() {
                                          tipo = v;
                                          otroTipo.clear();
                                        }),
                              ),
                              if (tipo == 'Otro') ...[
                                const SizedBox(height: 12),
                                ProductoCampoTexto(
                                  controller: otroTipo,
                                  etiqueta: 'Especifica el tipo *',
                                  icono: Icons.edit_rounded,
                                  validator: requerido,
                                ),
                              ],
                              const ProductoSeccion(
                                titulo: 'Precio y existencias',
                                icono: Icons.price_change_outlined,
                              ),
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ProductoCampoTexto(
                                      controller: precio,
                                      etiqueta: 'Precio *',
                                      icono: Icons.attach_money_rounded,
                                      formatoMiles: true,
                                      teclado: TextInputType.number,
                                      validator: (v) {
                                        final p = double.tryParse(
                                          (v ?? '')
                                              .replaceAll('.', '')
                                              .replaceAll(',', '.'),
                                        );

                                        return p == null || p <= 0
                                            ? 'Precio inválido'
                                            : null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: editando
                                        ? _campoSoloLectura(
                                            etiqueta: 'Existencias',
                                            valor: '${stock.text} unidades',
                                            icono: Icons.inventory_outlined,
                                          )
                                        : ProductoCampoTexto(
                                            controller: stock,
                                            etiqueta:
                                                'Stock inicial (máx. 100)',
                                            icono: Icons.inventory_outlined,
                                            teclado: TextInputType.number,
                                            validator: (v) {
                                              final s = int.tryParse(v ?? '');

                                              if (s == null || s < 0) {
                                                return 'Stock inválido';
                                              }

                                              if (s > 100) {
                                                return 'Máximo 100 unidades';
                                              }

                                              return null;
                                            },
                                          ),
                                  ),
                                ],
                              ),

                              // En edición las existencias no se escriben
                              // directamente: se ajustan con una entrada.
                              if (editando) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  'Las existencias se cambian con "Agregar stock" '
                                  '(registra una entrada con su lote y fecha).',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                              ],

                              // FECHA DE VENCIMIENTO DEL PRIMER LOTE (OPCIONAL)
                              if (!editando) ...[
                                const SizedBox(height: 12),
                                _campoFechaVencimiento(
                                  fecha: fechaVencimiento,
                                  onSeleccionar: () async {
                                    final hoy = DateTime.now();

                                    final elegida = await showDatePicker(
                                      context: context,
                                      initialDate: fechaVencimiento ?? hoy,
                                      firstDate: DateTime(
                                        hoy.year,
                                        hoy.month,
                                        hoy.day,
                                      ),
                                      lastDate: DateTime(hoy.year + 20),
                                      helpText:
                                          'Fecha de vencimiento del primer lote',
                                      cancelText: 'Cancelar',
                                      confirmText: 'Aceptar',
                                    );

                                    if (elegida != null) {
                                      actualizar(() {
                                        fechaVencimiento = elegida;
                                      });
                                    }
                                  },
                                  onLimpiar: () => actualizar(() {
                                    fechaVencimiento = null;
                                  }),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'La fecha es opcional. Si no la conoces, puedes registrar el lote sin fecha.',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                              ],

                              // CÁLCULO OPCIONAL DE PRECIO POR CAJA
                              if (!editando) ...[
                                const SizedBox(height: 20),
                                const ProductoSeccion(
                                  titulo: 'Cálculo de precio por caja',
                                  icono: Icons.calculate_outlined,
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    'Calcula cuánto cuesta cada unidad y obtén un precio de venta sugerido. Esta sección es opcional.',
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                ProductoCampoTexto(
                                  controller: costoCaja,
                                  etiqueta: 'Costo de compra de la caja',
                                  icono: Icons.inventory_2_outlined,
                                  formatoMiles: true,
                                  teclado: TextInputType.number,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ProductoCampoTexto(
                                        controller: unidadesCaja,
                                        etiqueta: 'Unidades por caja',
                                        icono: Icons.numbers_rounded,
                                        teclado: TextInputType.number,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ProductoCampoTexto(
                                        controller: porcentajeGanancia,
                                        etiqueta: 'Ganancia (%)',
                                        icono: Icons.trending_up_rounded,
                                        teclado:
                                            const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  height: 46,
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        calcularPrecioSugerido(actualizar),
                                    icon: const Icon(
                                      Icons.calculate_outlined,
                                    ),
                                    label: const Text(
                                      'Calcular precio sugerido',
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: productoAmarillo,
                                      side: BorderSide(
                                        color: productoAmarillo
                                            .withValues(alpha: 0.5),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                                if (precioSugeridoCalculado != null) ...[
                                  const SizedBox(height: 14),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.045,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(16),
                                      border: Border.all(
                                        color: productoAmarillo.withValues(
                                          alpha: 0.35,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Resultado del cálculo',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        _filaCalculo(
                                          'Costo por unidad',
                                          costoUnitarioCalculado!,
                                        ),
                                        const SizedBox(height: 7),
                                        _filaCalculo(
                                          'Ganancia por unidad',
                                          gananciaCalculada!,
                                        ),
                                        const Divider(
                                          color: Colors.white24,
                                          height: 22,
                                        ),
                                        const Text(
                                          'Precio de venta sugerido',
                                          style: TextStyle(
                                            color: Colors.white60,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '\$ ${ProductoCampoTexto.formatearMiles(
                                            precioSugeridoCalculado!
                                                .toStringAsFixed(0),
                                          )}',
                                          style: const TextStyle(
                                            color: productoAmarillo,
                                            fontSize: 23,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              precio.text =
                                                  ProductoCampoTexto
                                                      .formatearMiles(
                                                precioSugeridoCalculado!
                                                    .toStringAsFixed(0),
                                              );

                                              actualizar(() {});
                                            },
                                            icon: const Icon(
                                              Icons.check_circle_outline,
                                            ),
                                            label: const Text(
                                              'Usar este precio',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  productoAmarillo,
                                              foregroundColor:
                                                  const Color(0xFF0E2136),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],

                              const SizedBox(height: 22),
                              _botonGuardar(
                                () {
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }

                                  if (!editando &&
                                      !usarUrl &&
                                      imagen == null) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Selecciona una imagen o utiliza una URL.',
                                        ),
                                        behavior:
                                            SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }

                                  final tipoFinal = tipo == 'Otro'
                                      ? otroTipo.text.trim()
                                      : tipo!;

                                  Navigator.pop(dialogContext, {
                                    'nombre': nombre.text.trim(),
                                    'descripcion':
                                        descripcion.text.trim(),
                                    'codigoBarras':
                                        codigoBarras.text.trim().isEmpty
                                            ? null
                                            : codigoBarras.text.trim(),
                                    'precio': precio.text
                                        .replaceAll('.', '')
                                        .replaceAll(',', '.')
                                        .trim(),
                                    'categoria':
                                        '$categoria - $tipoFinal',
                                    'tipoProducto': tipoFinal,
                                    'stock': stock.text.trim(),
                                    'fechaVencimiento':
                                        fechaVencimiento == null
                                            ? null
                                            : _fechaParaBackend(
                                                fechaVencimiento!,
                                              ),
                                    'imagen': imagen,
                                    'imagenUrl':
                                        usarUrl ? url.text.trim() : null,
                                  });
                                },
                                texto: editando
                                    ? 'Guardar cambios'
                                    : 'Guardar producto',
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: OutlinedButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white70,
                                    side: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.18,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text('Cancelar'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } finally {
      await WidgetsBinding.instance.endOfFrame;

      nombre.dispose();
      descripcion.dispose();
      precio.dispose();
      stock.dispose();
      costoCaja.dispose();
      unidadesCaja.dispose();
      porcentajeGanancia.dispose();
      url.dispose();
      otroTipo.dispose();
      codigoBarras.dispose();
    }
  }

  // Formatea una fecha como YYYY-MM-DD para el backend.
  static String _fechaParaBackend(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '${fecha.year}-$mes-$dia';
  }

  // Campo opcional para la fecha de vencimiento del primer lote.
  static Widget _campoFechaVencimiento({
    required DateTime? fecha,
    required VoidCallback onSeleccionar,
    required VoidCallback onLimpiar,
  }) {
    final texto = fecha == null
        ? 'Sin fecha'
        : '${fecha.day.toString().padLeft(2, '0')}/'
            '${fecha.month.toString().padLeft(2, '0')}/'
            '${fecha.year}';

    return InkWell(
      onTap: onSeleccionar,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: ProductoEstilos.campo(
          'Fecha de vencimiento del primer lote',
          Icons.calendar_month_outlined,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                texto,
                style: TextStyle(
                  color: fecha == null ? Colors.white38 : Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            if (fecha != null)
              GestureDetector(
                onTap: onLimpiar,
                child: const Icon(
                  Icons.close,
                  color: Colors.white54,
                  size: 18,
                ),
              )
            else
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white38,
                size: 13,
              ),
          ],
        ),
      ),
    );
  }

  // Campo de solo lectura para mostrar datos que no se editan aquí.
  static Widget _campoSoloLectura({
    required String etiqueta,
    required String valor,
    required IconData icono,
  }) {
    return InputDecorator(
      decoration: ProductoEstilos.campo(etiqueta, icono),
      child: Text(
        valor,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
    );
  }

  static Widget _filaCalculo(
    String titulo,
    double valor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
        Text(
          '\$ ${ProductoCampoTexto.formatearMiles(
            valor.round().toString(),
          )}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  static Widget _encabezado(
    BuildContext context, {
    bool editando = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 12, 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: productoAmarillo.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              editando
                  ? Icons.edit_rounded
                  : Icons.inventory_2_rounded,
              color: productoAmarillo,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  editando
                      ? 'Editar producto'
                      : 'Registrar producto',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  editando
                      ? 'Actualiza la información del producto'
                      : 'Agrega un producto a tu inventario',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _botonGuardar(
    VoidCallback accion, {
    String texto = 'Guardar producto',
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: accion,
        icon: const Icon(Icons.save_rounded),
        label: Text(
          texto,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: productoAmarillo,
          foregroundColor: const Color(0xFF0E2136),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}