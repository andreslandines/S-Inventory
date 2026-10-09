import 'package:flutter/material.dart';

class ChatBurbuja extends StatelessWidget {
  final String texto;
  final bool esUsuario;
  final String? hora;

  const ChatBurbuja({
    super.key,
    required this.texto,
    required this.esUsuario,
    this.hora,
  });

  @override
  Widget build(BuildContext context) {
    final horaMostrar = hora ?? _horaActual();

    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Column(
          crossAxisAlignment: esUsuario ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: esUsuario ? const Color.fromARGB(255, 21, 78, 202) : const Color(0xFFF1F3F4),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(esUsuario ? 16 : 4),
                  bottomRight: Radius.circular(esUsuario ? 4 : 16),
                ),
              ),
              child: Text(
                texto,
                style: TextStyle(
                  color: esUsuario ? Colors.white : Colors.black87,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                horaMostrar,
                style: TextStyle(
                  color: Colors.black38,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  String _horaActual() {
    final ahora = DateTime.now();
    final hora = ahora.hour.toString().padLeft(2, '0');
    final minuto = ahora.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }
}