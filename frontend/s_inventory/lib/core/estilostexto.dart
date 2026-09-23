import 'package:flutter/material.dart';
import 'colores.dart';

class Estilotextos {

//Es el texto general de la aplicación.
  static TextStyle estilosletras = TextStyle(
    color: Colors.white,
    fontSize: 18,
     fontFamily: 'Roboto'
  );

//Es para los títulos principales de cada pantalla.
  static TextStyle Titulos = TextStyle(
    color: Colors.white,
    fontSize: 30,
    fontWeight: FontWeight.bold,
    fontFamily: 'Roboto'
  );

//Es para títulos que son más pequeños que el título principal.
  static TextStyle subtitulos = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w600,
     fontFamily: 'Roboto'
  );

//Es para el contenido normal de la pantalla.
  static TextStyle textoNormal = TextStyle(
    color: Colors.white,
    fontSize: 16,
     fontFamily: 'Roboto'
  );

//Es para información menos importante visualmente.
  static TextStyle textoSecundario = TextStyle(
    color: Color(0xFF8C9CAD),
    fontSize: 13,
     fontFamily: 'Roboto'
  );

//Es para información muy pequeña.
  static TextStyle textoPequeno = TextStyle(
    color: Color(0xFF8C9CAD),
    fontSize: 11,
     fontFamily: 'Roboto'
  );

//Es exclusivamente para el texto de los botones.
  static TextStyle textoBoton = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w600,
     fontFamily: 'Roboto'
  );

static const TextStyle label = TextStyle(
   color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w200,
     fontFamily: 'Roboto'
);

static const TextStyle textoOlvidasteContrasena = TextStyle(
  color: AppColors.fondoComponenteSeleccionado,
  fontSize: 14,
);

}
