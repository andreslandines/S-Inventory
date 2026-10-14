class MensajeBoxia {
  final String texto;
  final String rol; // 'user' | 'bot'
  final String hora; // "HH:mm"

  MensajeBoxia({
    required this.texto,
    required this.rol,
    required this.hora,
  });

  bool get esUsuario => rol == 'user';

  Map<String, dynamic> toJson() =>
      {'texto': texto, 'rol': rol, 'hora': hora};

  factory MensajeBoxia.fromJson(Map<String, dynamic> j) => MensajeBoxia(
        texto: j['texto'] ?? '',
        rol: j['rol'] ?? 'bot',
        hora: j['hora'] ?? '',
      );
}

class ChatBoxia {
  final String id;
  final String titulo;
  final DateTime fecha;
  final List<MensajeBoxia> mensajes;

  ChatBoxia({
    required this.id,
    required this.titulo,
    required this.fecha,
    List<MensajeBoxia>? mensajes,
  }) : mensajes = mensajes ?? [];

  ChatBoxia.vacio()
      : id = DateTime.now().millisecondsSinceEpoch.toString(),
        titulo = 'Nuevo chat',
        fecha = DateTime.now(),
        mensajes = [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'fecha': fecha.toIso8601String(),
        'mensajes': mensajes.map((m) => m.toJson()).toList(),
      };

  factory ChatBoxia.fromJson(Map<String, dynamic> j) => ChatBoxia(
        id: j['id'] ?? '',
        titulo: j['titulo'] ?? 'Nuevo chat',
        fecha: DateTime.tryParse(j['fecha'] ?? '') ?? DateTime.now(),
        mensajes: (j['mensajes'] as List? ?? [])
            .map((m) => MensajeBoxia.fromJson(m as Map<String, dynamic>))
            .toList(),
      );
}