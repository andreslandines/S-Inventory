
import 'package:flutter/material.dart';
import 'colores.dart';

class Estilotextos {
  Estilotextos._();

  static const String fuente = 'Roboto';

  // Jerarquía de títulos
  static const TextStyle Titulos = TextStyle(
    color: AppColors.textoPrincipal,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontFamily: fuente,
  );

  static const TextStyle subtitulos = TextStyle(
    color: AppColors.textoPrincipal,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontFamily: fuente,
  );

  static const TextStyle tituloSeccion = TextStyle(
    color: AppColors.textoPrincipal,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: fuente,
  );

  // Textos generales
  static const TextStyle estilosletras = TextStyle(
    color: AppColors.textoPrincipal,
    fontSize: 18,
    fontFamily: fuente,
  );

  static const TextStyle textoNormal = TextStyle(
    color: AppColors.textoPrincipal,
    fontSize: 16,
    fontFamily: fuente,
  );

  static const TextStyle textoSecundario = TextStyle(
    color: AppColors.textoSecundario,
    fontSize: 13,
    fontFamily: fuente,
  );

  static const TextStyle textoPequeno = TextStyle(
    color: AppColors.textoSecundario,
    fontSize: 12,
    fontFamily: fuente,
  );

  // Botones y formularios
  static const TextStyle textoBoton = TextStyle(
    color: AppColors.textoPrincipal,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: fuente,
  );

  static const TextStyle label = TextStyle(
    color: AppColors.textoPrincipal,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: fuente,
  );

  static const TextStyle textoOlvidasteContrasena =
      TextStyle(
    color: AppColors.secondary,
    fontSize: 14,
    fontFamily: fuente,
  );

  static const TextStyle textoamarillo = TextStyle(
    color: AppColors.advertencia,
    fontSize: 12,
    fontFamily: fuente,
  );
}
