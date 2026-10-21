import 'package:flutter/material.dart';
import 'package:s_inventory/models/chat_boxia.dart';
import '../PanelHistorial.dart';


class ChatHeader extends StatelessWidget {
  final Function(ChatBoxia)onAbrir;
  final VoidCallback onNuevo;
  
  const ChatHeader({super.key, required this.onAbrir, required this.onNuevo});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color.fromARGB(255, 24, 74, 150),
                child: Icon(Icons.auto_awesome, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Asesor S-Inventory',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                  Text(
                    'En linea - Respuestas al instante',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ],
              ),
              Spacer(),
              IconButton( tooltip: 'Historial',icon: const Icon( Icons.history, color: Color.fromARGB(255, 49, 141, 228),),
                onPressed: () => showModalBottomSheet(context: context,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => PanelHistorial(
                onAbrir: onAbrir,
                onNuevo: onNuevo,
                ),
              ),
            ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}