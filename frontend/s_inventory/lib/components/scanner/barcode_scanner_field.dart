
import 'package:flutter/material.dart';
import 'package:s_inventory/core/scanner/barcode_scanner_page.dart';

class BarcodeScannerField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const BarcodeScannerField({
    super.key,
    required this.controller,
    this.label = 'Código de barras',
    this.hint = 'Escribe o escanea el código',
    this.enabled = true,
    this.onChanged,
  });

  static const Color amarillo = Color(0xFFFFC400);

  Future<void> _escanear(BuildContext context) async {
    if (!enabled) return;

    final codigo = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const BarcodeScannerPage(),
      ),
    );

    if (!context.mounted || codigo == null || codigo.trim().isEmpty) {
      return;
    }

    final codigoLimpio = codigo.trim();

    controller.value = TextEditingValue(
      text: codigoLimpio,
      selection: TextSelection.collapsed(
        offset: codigoLimpio.length,
      ),
    );

    onChanged?.call(codigoLimpio);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return TextField(
          controller: controller,
          enabled: enabled,
          onChanged: onChanged,
          keyboardType: TextInputType.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            labelStyle: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
            hintStyle: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
            prefixIcon: const Icon(
              Icons.qr_code_2_rounded,
              color: amarillo,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (value.text.isNotEmpty)
                  IconButton(
                    tooltip: 'Borrar código',
                    onPressed: enabled
                        ? () {
                            controller.clear();
                            onChanged?.call('');
                          }
                        : null,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white60,
                    ),
                  ),
                IconButton(
                  tooltip: 'Escanear código de barras',
                  onPressed: enabled
                      ? () => _escanear(context)
                      : null,
                  icon: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: amarillo,
                  ),
                ),
              ],
            ),
            filled: true,
            fillColor: const Color(0xFF202B3B),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: amarillo,
                width: 1.2,
              ),
            ),
          ),
        );
      },
    );
  }
}
