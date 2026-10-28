import 'package:flutter/material.dart';
import 'package:s_inventory/components/chat/ChatModal.dart';
import 'package:s_inventory/core/colores.dart';

class Boxia extends StatefulWidget {
  const Boxia({super.key});

  @override
  State<Boxia> createState() => _BoxiaState();
}

class _BoxiaState extends State<Boxia> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 164, 161, 161).withOpacity(0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ChatBoxiaModal(),
    );
  }
}