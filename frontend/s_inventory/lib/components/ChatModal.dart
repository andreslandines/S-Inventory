import 'package:flutter/material.dart';
import 'package:s_inventory/components/chat/ChatBoxIABurbuja.dart';
import 'package:s_inventory/components/chat/ChatHeader.dart';
import 'package:s_inventory/components/chat/ChatInputField.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/chatboxiaservice.dart';

class ChatBoxiaModal extends StatefulWidget {
  final bool pantallaCompleta;
  const ChatBoxiaModal({super.key, this.pantallaCompleta = false});

  @override
  State<ChatBoxiaModal> createState() => _ChatBoxiaModalState();
}

class _ChatBoxiaModalState extends State<ChatBoxiaModal> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String _sesionId;
  final List<Map<String, String>> _mensajes = [];
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _obtenerSesionDelDia();
     _mensajes.add({
      'role': 'bot',
      'text': 'Hola! Soy Boxi, tu asistente de inventario. Puedo ayudarte a buscar productos, revisar stock, detectar vencimientos y generar reportes. ¿En que te puedo ayudar el dia de hoy?',
      'hora': _formatearHora(),
    });
  }

  Future<void> _obtenerSesionDelDia() async {
    final prefs = await SharedPreferences.getInstance();
    final hoy = _fechaDeHoy();
    final sesionGuardada = prefs.getString('sesion_boxia');

    if (sesionGuardada != null && sesionGuardada.startsWith('sesion_$hoy')) {


      _sesionId = sesionGuardada;

    } else {
      _sesionId = 'sesion_$hoy';
      await prefs.setString('sesion_boxia', _sesionId);
    }
  }

  String _fechaDeHoy() {
    final ahora = DateTime.now();
    final mes = ahora.month.toString().padLeft(2, '0');
    final dia = ahora.day.toString().padLeft(2, '0');
    return '${ahora.year}-$mes-$dia';
  }

  String _formatearHora() {
    final ahora = DateTime.now();
    final hora = ahora.hour.toString().padLeft(2, '0');
    final minuto = ahora.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  void _enviarMensaje() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty || _cargando) return;

    _controller.clear();
    setState(() {
      _mensajes.add({
        'role': 'user',
        'text': texto,
        'hora': _formatearHora(),
      });
      _cargando = true;
    });

    _scrollHaciaAbajo();

    try {
      final respuesta = await ChatBoxIAService.enviarMensaje(
        texto,
        sesionId: _sesionId,
      );

      if (mounted) {
        setState(() {
          _mensajes.add({
            'role': 'bot',
            'text': respuesta,
            'hora': _formatearHora(),
          });
          _cargando = false;
        });
        _scrollHaciaAbajo();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _mensajes.add({
            'role': 'bot',
            'text': 'Lo siento, no pude conectarme. Intenta de nuevo.',
            'hora': _formatearHora(),
          });
          _cargando = false;
        });
        _scrollHaciaAbajo();
      }
    }
  }

  void _scrollHaciaAbajo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
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
      height: widget.pantallaCompleta
          ? MediaQuery.of(context).size.height
          : MediaQuery.of(context).size.height * 0.78,
      margin: EdgeInsets.only(bottom: bottomInset),
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
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 1150),
                  curve: Curves.easeOutBack,
                  builder: (context, valor, child) {
                    return Transform.scale(
                      scale: valor,
                      child: Opacity(
                        opacity: ((valor - 0.8) / 0.2).clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: ChatBurbuja(
                    texto: item['text']!,
                    esUsuario: item['role'] == 'user',
                    hora: item['hora'],
                  ),
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
                    height:  14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color.fromARGB(255,  21,  78, 202)),
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