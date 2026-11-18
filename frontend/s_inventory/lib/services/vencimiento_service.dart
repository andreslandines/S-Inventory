
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class VencimientoService {
  // OBTENER TOKEN DE AUTENTICACIÓN
  Future<String> _obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      throw Exception(
        'No se encontró el token. Inicia sesión nuevamente.',
      );
    }

    return token;
  }

  // HEADERS PARA CONSULTAS AUTENTICADAS
  Future<Map<String, String>> _headers({
    bool autenticado = false,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (autenticado) {
      final token = await _obtenerToken();
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // DECODIFICAR RESPUESTA
  dynamic _decodificarRespuesta(String cuerpo) {
    if (cuerpo.isEmpty) return null;

    try {
      return jsonDecode(cuerpo);
    } catch (_) {
      throw Exception(
        'El servidor devolvió una respuesta no válida.',
      );
    }
  }

  // OBTENER MENSAJE DE ERROR
  String _mensajeError(
    dynamic datos,
    int codigo,
  ) {
    if (datos is Map) {
      return datos['error']?.toString() ??
          datos['message']?.toString() ??
          'Error HTTP $codigo.';
    }

    return 'Error HTTP $codigo.';
  }

  // CONVERTIR RESPUESTA EN LISTA
  List<Map<String, dynamic>> _convertirLista(
    dynamic datos,
  ) {
    if (datos is! List) {
      throw Exception(
        'La respuesta de lotes no tiene un formato válido.',
      );
    }

    return datos.map<Map<String, dynamic>>((elemento) {
      return Map<String, dynamic>.from(elemento);
    }).toList();
  }

  // CONSULTAR TODOS LOS LOTES
  Future<List<Map<String, dynamic>>> obtenerLotes() async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/vencimientos',
    );

    final respuesta = await http.get(
      url,
      headers: await _headers(),
    );

    final datos = _decodificarRespuesta(
      respuesta.body,
    );

    if (respuesta.statusCode != 200) {
      throw Exception(
        _mensajeError(datos, respuesta.statusCode),
      );
    }

    return _convertirLista(datos);
  }

  // CONSULTAR LOTES DE UN PRODUCTO
  Future<List<Map<String, dynamic>>> obtenerLotesPorProducto(
    String idProducto,
  ) async {
    final id = idProducto.trim();

    if (id.isEmpty || int.tryParse(id) == null) {
      throw Exception(
        'El identificador del producto no es válido.',
      );
    }

    final lotes = await obtenerLotes();

    return lotes.where((lote) {
      final producto = lote['productos'];

      if (producto is! Map) return false;

      return producto['id_productos'].toString() == id;
    }).toList();
  }

  // REGISTRAR UNA NUEVA ENTRADA DE MERCANCÍA
  Future<Map<String, dynamic>> registrarEntrada({
    required String idProducto,
    required int cantidad,
    String? fechaVencimiento,
  }) async {
    final id = int.tryParse(idProducto.trim());

    if (id == null || id <= 0) {
      throw Exception(
        'Selecciona un producto válido.',
      );
    }

    if (cantidad <= 0) {
      throw Exception(
        'La cantidad debe ser mayor que cero.',
      );
    }

    final fecha = fechaVencimiento?.trim();

    if (fecha != null && fecha.isNotEmpty) {
      final formatoFecha = RegExp(
        r'^\d{4}-\d{2}-\d{2}$',
      );

      if (!formatoFecha.hasMatch(fecha)) {
        throw Exception(
          'La fecha debe tener el formato AAAA-MM-DD.',
        );
      }
    }

    final url = Uri.parse(
      '${ApiConfig.baseUrl}/vencimientos/registrar',
    );

    final respuesta = await http.post(
      url,
      headers: {
        ...await _headers(autenticado: true),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id_producto': id,
        'cantidad': cantidad,
        'fecha_vencimiento':
            fecha == null || fecha.isEmpty ? null : fecha,
      }),
    );

    final datos = _decodificarRespuesta(
      respuesta.body,
    );

    if (respuesta.statusCode == 200 ||
        respuesta.statusCode == 201) {
      debugPrint(
        'ENTRADA REGISTRADA: $datos',
      );

      if (datos is Map) {
        return Map<String, dynamic>.from(datos);
      }

      return {};
    }

    throw Exception(
      _mensajeError(datos, respuesta.statusCode),
    );
  }

  // CONSULTAR LOTES PRÓXIMOS A VENCER
  Future<List<Map<String, dynamic>>> obtenerProximosAVencer({
    int dias = 30,
  }) async {
    if (dias < 1 || dias > 365) {
      throw Exception(
        'El periodo debe estar entre 1 y 365 días.',
      );
    }

    final url = Uri.parse(
      '${ApiConfig.baseUrl}/vencimientos/proximos',
    ).replace(
      queryParameters: {
        'dias': dias.toString(),
      },
    );

    final respuesta = await http.get(
      url,
      headers: await _headers(),
    );

    final datos = _decodificarRespuesta(
      respuesta.body,
    );

    if (respuesta.statusCode != 200) {
      throw Exception(
        _mensajeError(datos, respuesta.statusCode),
      );
    }

    return _convertirLista(datos);
  }

  // CONSULTAR LOTES VENCIDOS
  Future<List<Map<String, dynamic>>> obtenerLotesVencidos() async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/vencimientos/vencidos',
    );

    final respuesta = await http.get(
      url,
      headers: await _headers(),
    );

    final datos = _decodificarRespuesta(
      respuesta.body,
    );

    if (respuesta.statusCode != 200) {
      throw Exception(
        _mensajeError(datos, respuesta.statusCode),
      );
    }

    return _convertirLista(datos);
  }

  // ACTUALIZAR FECHA DE VENCIMIENTO
  Future<Map<String, dynamic>> actualizarFechaVencimiento({
    required String idVencimiento,
    String? fechaVencimiento,
  }) async {
    final id = int.tryParse(idVencimiento.trim());

    if (id == null || id <= 0) {
      throw Exception(
        'El identificador del lote no es válido.',
      );
    }

    final fecha = fechaVencimiento?.trim();

    if (fecha != null && fecha.isNotEmpty) {
      final formatoFecha = RegExp(
        r'^\d{4}-\d{2}-\d{2}$',
      );

      if (!formatoFecha.hasMatch(fecha)) {
        throw Exception(
          'La fecha debe tener el formato AAAA-MM-DD.',
        );
      }
    }

    final url = Uri.parse(
      '${ApiConfig.baseUrl}/vencimientos/actualizar/$id',
    );

    final respuesta = await http.put(
      url,
      headers: {
        ...await _headers(autenticado: true),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fecha_vencimiento':
            fecha == null || fecha.isEmpty ? null : fecha,
      }),
    );

    final datos = _decodificarRespuesta(
      respuesta.body,
    );

    if (respuesta.statusCode == 200) {
      if (datos is Map) {
        return Map<String, dynamic>.from(datos);
      }

      return {};
    }

    throw Exception(
      _mensajeError(datos, respuesta.statusCode),
    );
  }
}
