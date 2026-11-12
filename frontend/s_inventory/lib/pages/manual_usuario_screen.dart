
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class ManualUsuarioScreen extends StatefulWidget {
  const ManualUsuarioScreen({super.key});

  @override
  State<ManualUsuarioScreen> createState() =>
      _ManualUsuarioScreenState();
}

class _ManualUsuarioScreenState
    extends State<ManualUsuarioScreen> {
  String? rutaPDF;
  String? error;

  bool cargando = true;
  int paginas = 0;
  int paginaActual = 0;

  @override
  void initState() {
    super.initState();
    cargarPDF();
  }

  Future<void> cargarPDF() async {
    try {
      if (mounted) {
        setState(() {
          cargando = true;
          error = null;
          rutaPDF = null;
          paginas = 0;
          paginaActual = 0;
        });
      }

      // Cargar el PDF desde los recursos de Flutter.
      final datos = await rootBundle.load(
        'assets/documents/manual_usuario.pdf',
      );

      // Obtener una carpeta temporal directamente desde Dart.
      // No requiere el plugin path_provider.
      final directorio = await Directory.systemTemp.createTemp(
        'sinventory_manual_',
      );

      final archivo = File(
        '${directorio.path}/manual_usuario.pdf',
      );

      // Guardar el PDF en el almacenamiento temporal.
      await archivo.writeAsBytes(
        datos.buffer.asUint8List(
          datos.offsetInBytes,
          datos.lengthInBytes,
        ),
        flush: true,
      );

      // Comprobar que el archivo se haya guardado correctamente.
      if (!await archivo.exists()) {
        throw Exception('No se pudo crear el archivo PDF.');
      }

      if (await archivo.length() == 0) {
        throw Exception('El archivo PDF está vacío.');
      }

      if (!mounted) return;

      setState(() {
        rutaPDF = archivo.path;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
        error = e.toString();
      });
    }
  }

  void mostrarError(dynamic e) {
    if (!mounted) return;

    setState(() {
      cargando = false;
      error = 'Error al visualizar el PDF: $e';
    });
  }

  @override
  Widget build(BuildContext context) {
    const fondo = Color(0xFF111827);
    const acento = Color(0xFFFFC400);

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        backgroundColor: fondo,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Manual de usuario',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: cargando
            ? const Center(
                child: CircularProgressIndicator(
                  color: acento,
                ),
              )
            : error != null || rutaPDF == null
                ? Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.picture_as_pdf_rounded,
                            color: Colors.redAccent,
                            size: 55,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'No se pudo cargar el manual.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            error ?? 'Archivo no disponible.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: cargarPDF,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: acento,
                              foregroundColor: fondo,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.menu_book_rounded,
                              color: acento,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              paginas == 0
                                  ? 'Abriendo documento...'
                                  : 'Página ${paginaActual + 1} de $paginas',
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: PDFView(
                          filePath: rutaPDF!,
                          enableSwipe: true,
                          swipeHorizontal: false,
                          autoSpacing: true,
                          pageFling: true,
                          onRender: (total) {
                            if (!mounted) return;

                            setState(() {
                              paginas = total ?? 0;
                            });
                          },
                          onPageChanged: (pagina, total) {
                            if (!mounted) return;

                            setState(() {
                              paginaActual = pagina ?? 0;
                            });
                          },
                          onError: (e) {
                            mostrarError(e);
                          },
                          onPageError: (pagina, e) {
                            mostrarError(e);
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
