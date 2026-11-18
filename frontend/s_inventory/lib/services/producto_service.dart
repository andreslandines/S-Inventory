
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import 'api_config.dart';

class ProductoService {
  // VALIDAR STOCK INICIAL: MÁXIMO 100 UNIDADES
  int _validarStock(String valor) {
    final cantidad = int.tryParse(valor.trim());

    if (cantidad == null || cantidad < 0) {
      throw Exception(
        'El stock debe ser un número válido.',
      );
    }

    if (cantidad > 100) {
      throw Exception(
        'El stock máximo permitido por producto es de 100 unidades.',
      );
    }

    return cantidad;
  }

  // NORMALIZAR PRECIO PARA ENVIAR AL BACKEND
  String _normalizarPrecio(String valor) {
    final normalizado = valor
        .trim()
        .replaceAll('.', '')
        .replaceAll(',', '.');

    final numero = double.tryParse(normalizado);

    if (numero == null || numero <= 0) {
      throw Exception(
        'El precio debe ser un número mayor que cero.',
      );
    }

    return numero.toString();
  }

  // VALIDAR FECHA DE VENCIMIENTO OPCIONAL
  String? _validarFechaVencimiento(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return null;
    }

    final fecha = valor.trim();

    final formatoValido = RegExp(
      r'^\d{4}-\d{2}-\d{2}$',
    ).hasMatch(fecha);

    if (!formatoValido) {
      throw Exception(
        'La fecha de vencimiento debe tener el formato YYYY-MM-DD.',
      );
    }

    final partes = fecha.split('-');

    final anio = int.parse(partes[0]);
    final mes = int.parse(partes[1]);
    final dia = int.parse(partes[2]);

    final fechaConvertida = DateTime(
      anio,
      mes,
      dia,
    );

    if (fechaConvertida.year != anio ||
        fechaConvertida.month != mes ||
        fechaConvertida.day != dia) {
      throw Exception(
        'La fecha de vencimiento no es válida.',
      );
    }

    return fecha;
  }

  // OBTENER PRODUCTOS
  Future<List<Map<String, dynamic>>> obtenerProductos() async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/pro/productos',
    );

    final respuesta = await http.get(
      url,
      headers: ApiConfig.headers,
    );

    if (respuesta.statusCode != 200) {
      throw Exception(
        'Error al consultar productos: ${respuesta.statusCode}',
      );
    }

    final dynamic datos = jsonDecode(respuesta.body);

    if (datos is! List) {
      throw Exception(
        'La respuesta de productos no es una lista.',
      );
    }

    return datos.map<Map<String, dynamic>>((producto) {
      return Map<String, dynamic>.from(producto);
    }).toList();
  }

  // REGISTRAR PRODUCTO CON STOCK INICIAL (PRIMER LOTE)
  Future<Map<String, dynamic>> crearProducto({
    required String nombre,
    required String descripcion,
    required String precio,
    required String categoria,
    required String stock,
    String? codigoBarras,
    String? fechaVencimiento,
    List<int>? imagenBytes,
    String? nombreImagen,
    String? imagenUrl,
  }) async {
    final stockValidado = _validarStock(stock);
    final precioValidado = _normalizarPrecio(precio);

    final fechaValidada = _validarFechaVencimiento(
      fechaVencimiento,
    );

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception(
        'No se encontró el token. Inicia sesión nuevamente.',
      );
    }

    final url = Uri.parse(
      '${ApiConfig.baseUrl}/pro/productoscrear',
    );

    final solicitud = http.MultipartRequest(
      'POST',
      url,
    );

    solicitud.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    solicitud.fields.addAll({
      'nombre': nombre.trim(),
      'descripcion': descripcion.trim(),
      'precio': precioValidado,
      'categoria': categoria.trim(),
      'stock': stockValidado.toString(),
      'codigo_barras': codigoBarras?.trim() ?? '',
    });

    // ENVIAR FECHA DEL LOTE INICIAL SI FUE SELECCIONADA
    if (fechaValidada != null) {
      solicitud.fields['fecha_vencimiento'] = fechaValidada;
    }

    final urlImagen = imagenUrl?.trim() ?? '';

    if (imagenBytes != null && imagenBytes.isNotEmpty) {
      solicitud.files.add(
        http.MultipartFile.fromBytes(
          'imagen',
          imagenBytes,
          filename: nombreImagen ?? 'producto.jpg',
        ),
      );
    } else if (urlImagen.isNotEmpty) {
      solicitud.fields['imagen_url'] = urlImagen;
    } else {
      throw Exception(
        'Selecciona una imagen o proporciona una URL válida.',
      );
    }

    debugPrint(
      'CÓDIGO ENVIADO AL BACKEND: '
      '${solicitud.fields['codigo_barras']}',
    );

    debugPrint(
      'PRECIO ENVIADO AL BACKEND: $precioValidado',
    );

    debugPrint(
      'STOCK INICIAL / PRIMER LOTE: $stockValidado',
    );

    debugPrint(
      'FECHA VENCIMIENTO LOTE INICIAL: '
      '${fechaValidada ?? 'Sin fecha'}',
    );

    final respuesta = await solicitud.send();

    final cuerpo = await respuesta.stream.bytesToString();
    final datos = _decodificarRespuesta(cuerpo);

    if (respuesta.statusCode == 200 ||
        respuesta.statusCode == 201) {
      return datos;
    }

    throw Exception(
      datos['error'] ??
          datos['message'] ??
          'No se pudo registrar el producto '
              '(código ${respuesta.statusCode}).',
    );
  }

  // ACTUALIZAR PRODUCTO SIN MODIFICAR STOCK NI LOTES
  Future<void> actualizarProducto({
    required String id,
    required String nombre,
    required String descripcion,
    required String precio,
    required String categoria,
    String? codigoBarras,
    XFile? imagenArchivo,
  }) async {
    final precioValidado = _normalizarPrecio(precio);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception(
        'Inicia sesión nuevamente.',
      );
    }

    final url = Uri.parse(
      '${ApiConfig.baseUrl}/pro/productoseditar/$id',
    );

    final solicitud = http.MultipartRequest(
      'PUT',
      url,
    );

    solicitud.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    solicitud.fields.addAll({
      'nombre': nombre.trim(),
      'descripcion': descripcion.trim(),
      'precio': precioValidado,
      'categoria': categoria.trim(),
      'codigo_barras': codigoBarras?.trim() ?? '',
    });

    // SOLO SE ADJUNTA LA IMAGEN CUANDO EL USUARIO SELECCIONA OTRA.
    if (imagenArchivo != null) {
      final bytes = await imagenArchivo.readAsBytes();

      if (bytes.isEmpty) {
        throw Exception(
          'La imagen seleccionada está vacía.',
        );
      }

      solicitud.files.add(
        http.MultipartFile.fromBytes(
          'imagen',
          bytes,
          filename: imagenArchivo.name,
        ),
      );
    }

    debugPrint(
      'PRECIO ACTUALIZADO: $precioValidado',
    );

    debugPrint(
      'STOCK: NO SE MODIFICA DESDE EDICIÓN',
    );

    debugPrint(
      'LOTES Y FECHAS: NO SE MODIFICAN DESDE EDICIÓN',
    );

    final respuesta = await solicitud.send();

    final cuerpo = await respuesta.stream.bytesToString();
    final datos = _decodificarRespuesta(cuerpo);

    if (respuesta.statusCode == 200 ||
        respuesta.statusCode == 201) {
      return;
    }

    throw Exception(
      datos['error'] ??
          datos['message'] ??
          'No se pudo actualizar el producto '
              '(código ${respuesta.statusCode}).',
    );
  }

  // ELIMINAR PRODUCTO
  Future<void> eliminarProducto(String id) async {
    final idProducto = id.trim();

    if (idProducto.isEmpty || idProducto == 'null') {
      throw Exception(
        'El identificador del producto no es válido.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception(
        'Inicia sesión nuevamente.',
      );
    }

    final url = Uri.parse(
      '${ApiConfig.baseUrl}/pro/productoseliminar/$idProducto',
    );

    final respuesta = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (respuesta.statusCode == 200 ||
        respuesta.statusCode == 204) {
      return;
    }

    String detalle = respuesta.body.trim();

    if (detalle.isNotEmpty) {
      try {
        final datos = jsonDecode(detalle);

        if (datos is Map) {
          detalle = datos['error']?.toString() ??
              datos['message']?.toString() ??
              detalle;
        }
      } catch (_) {}
    }

    throw Exception(
      'Error al eliminar producto '
      '(HTTP ${respuesta.statusCode}): $detalle',
    );
  }

  // DECODIFICAR RESPUESTA DEL SERVIDOR
  Map<String, dynamic> _decodificarRespuesta(
    String cuerpo,
  ) {
    if (cuerpo.isEmpty) return {};

    try {
      final decoded = jsonDecode(cuerpo);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      return {};
    } catch (_) {
      throw Exception(
        'El servidor devolvió una respuesta no válida.',
      );
    }
  }
}
