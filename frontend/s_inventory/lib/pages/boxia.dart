import 'package:flutter/material.dart';
import 'package:s_inventory/components/ChatModal.dart';
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
        color: AppColors.fondoComponentes,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white12, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const ChatBoxiaModal(),
    );
  }
}