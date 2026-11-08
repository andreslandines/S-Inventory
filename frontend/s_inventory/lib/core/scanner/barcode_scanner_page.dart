
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() =>
      _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  late final MobileScannerController _controller;

  bool _hasScanned = false;

  static const Color backgroundColor = Color(0xFF111827);
  static const Color accentColor = Color(0xFFFFC400);

  @override
  void initState() {
    super.initState();

    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_hasScanned) return;

    for (final barcode in capture.barcodes) {
      final String? code = barcode.rawValue;

      if (code != null && code.trim().isNotEmpty) {
        _hasScanned = true;

        await _controller.stop();

        if (!mounted) return;

        Navigator.of(context).pop(code.trim());
        return;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Escanear código de barras',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Activar o desactivar flash',
            onPressed: () => _controller.toggleTorch(),
            icon: const Icon(Icons.flashlight_on_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          Positioned.fill(
            child: Column(
              children: [
                const Spacer(),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Ubica el código de barras dentro del recuadro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Container(
                  width: 290,
                  height: 175,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: accentColor,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'El código se reconocerá automáticamente',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),

                const Spacer(),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: backgroundColor.withValues(alpha: 0.9),
                  child: const Text(
                    'S-Inventory',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
