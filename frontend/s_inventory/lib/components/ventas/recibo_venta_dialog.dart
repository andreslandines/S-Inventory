
import 'package:flutter/material.dart';
import 'package:s_inventory/core/colores.dart';
import 'package:s_inventory/services/ventas_servicios.dart';

class ReciboVentaDialog extends StatelessWidget {
  final String id;
  final Map<String, dynamic> venta;

  const ReciboVentaDialog({
    super.key,
    required this.id,
    required this.venta,
  });

  double _numero(dynamic valor) {
    if (valor is num) return valor.toDouble();

    return double.tryParse(
          valor?.toString().replaceAll(',', '.') ?? '',
        ) ??
        0;
  }

  String _dinero(dynamic valor) {
    final numero = _numero(valor);
    final entero = numero.round().toString();

    final resultado = entero.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return '\$$resultado';
  }

  String _fecha(dynamic valor) {
    if (valor == null) return 'Fecha no disponible';

    final fecha = DateTime.tryParse(valor.toString());

    if (fecha == null) return valor.toString();

    final local = fecha.toLocal();

    final dia = local.day.toString().padLeft(2, '0');
    final mes = local.month.toString().padLeft(2, '0');
    final anio = local.year.toString();

    final hora = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minuto = local.minute.toString().padLeft(2, '0');
    final periodo = local.hour >= 12 ? 'p. m.' : 'a. m.';

    return '$dia/$mes/$anio  ·  $hora:$minuto $periodo';
  }

  Widget _separador() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: List.generate(
          45,
          (index) => Expanded(
            child: Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              color: Colors.white24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _producto(Map<String, dynamic> detalle) {
    final nombre =
        detalle['nombre_producto']?.toString() ??
        detalle['nombre']?.toString() ??
        'Producto';

    final cantidad = _numero(detalle['cantidad']).toInt();
    final precio = _numero(detalle['precio_unitario']);
    final subtotal = cantidad * precio;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nombre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$cantidad x ${_dinero(precio)}',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ),
              Text(
                _dinero(subtotal),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dato(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirTicket(Map<String, dynamic> datos) {
    final detallesRaw = datos['detalles'];

    final detalles = detallesRaw is List
        ? detallesRaw
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
        : <Map<String, dynamic>>[];

    final total = _numero(datos['total']);
    final unidades = detalles.fold<int>(
      0,
      (suma, detalle) =>
          suma + _numero(detalle['cantidad']).toInt(),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2533),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ENCABEZADO
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: AppColors.accent,
                    size: 29,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'S- INVENTORY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'TICKET DE VENTA',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          _separador(),

          // INFORMACIÓN DE LA VENTA
          Center(
            child: Column(
              children: [
                const Text(
                  'NÚMERO DE VENTA',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '#${datos['id_venta'] ?? id}',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.white54,
                      size: 13,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _fecha(datos['fecha']),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          _separador(),

          // PRODUCTOS
          const Text(
            'DETALLE DE PRODUCTOS',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),

          const Row(
            children: [
              Expanded(
                child: Text(
                  'PRODUCTO',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'SUBTOTAL',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),
          const Divider(color: Colors.white24, height: 1),

          if (detalles.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No hay productos registrados.',
                  style: TextStyle(color: Colors.white60),
                ),
              ),
            )
          else
            ...detalles.map(_producto),

          const Divider(color: Colors.white24, height: 1),

          const SizedBox(height: 10),

          // RESUMEN
          _dato('Cantidad de productos', '${detalles.length}'),
          _dato('Total de unidades', '$unidades'),

          _separador(),

          // TOTAL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'TOTAL A PAGAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                _dinero(total),
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          _separador(),

          // PIE DEL TICKET
          const Center(
            child: Column(
              children: [
                Icon(
                  Icons.favorite_rounded,
                  color: AppColors.accent,
                  size: 19,
                ),
                SizedBox(height: 8),
                Text(
                  '¡GRACIAS POR SU COMPRA!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.7,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Conserve este comprobante.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.fondo,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.white.withOpacity(0.10),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 440,
          maxHeight: 720,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.accent,
                    size: 23,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Comprobante de venta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white24),

              Flexible(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: VentaService().obtenerVentaPorId(id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(35),
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Color(0xFFFF7777),
                              size: 35,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'No se pudo cargar el recibo.',
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              '${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final datos = snapshot.data ?? venta;

                    return SingleChildScrollView(
                      child: _construirTicket(datos),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Cerrar recibo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: BorderSide(
                      color: AppColors.accent.withOpacity(0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
}
