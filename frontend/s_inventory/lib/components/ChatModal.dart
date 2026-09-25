import 'package:flutter/material.dart';
import '../services/chatboxiaservice.dart';
import 'chat/ChatHeader.dart';
import 'chat/ChatBoxIABurbuja.dart';
import 'chat/ChatInputField.dart';

class ChatMimosModal extends StatefulWidget {
  const ChatMimosModal({super.key});

  @override
  State<ChatMimosModal> createState() => _ChatMimosModalState();
}

class _ChatMimosModalState extends State<ChatMimosModal> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _mensajes = [
    {
      'role': 'bot',
      'text': 'Hola! Bienvenido a S-Inventory. ¿Qué producto, precio, stock o fecha de vencimiento te gustaría conocer?',
    }
  ];
  bool _cargando = false;

  void _enviarMensaje() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty || _cargando) return;

    _controller.clear();
    setState(() {
      _mensajes.add({'role': 'user', 'text': texto});
      _cargando = true;
    });

    _scrollHaciaAbajo();

    final respuesta = await ChatBoxIAService.enviarMensaje(texto);

    if (mounted) {
      setState(() {
        _mensajes.add({'role': 'bot', 'text': respuesta});
        _cargando = false;
      });
      _scrollHaciaAbajo();
    }
  }

  void _scrollHaciaAbajo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const ChatHeader(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final item = _mensajes[index];
                return ChatBurbuja(
                  texto: item['text']!,
                  esUsuario: item['role'] == 'user',
                );
              },
            ),
          ),
          if (_cargando)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color.fromARGB(255, 21, 78, 202)),
                  ),
                  SizedBox(width: 8),
                  Text('El asesor esta respondiendo...', style: TextStyle(color: Colors.black45, fontSize: 12)),
                ],
              ),
            ),
          ChatInputField(
            controller: _controller,
            cargando: _cargando,
            onEnviar: _enviarMensaje,
          ),
        ],
      ),
    );
  }
}