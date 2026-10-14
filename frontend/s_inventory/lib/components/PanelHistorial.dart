import 'package:flutter/material.dart';
import '../models/chat_boxia.dart';
import 'package:s_inventory/components/ChatBoxiaStorage.dart';
import '../utils/fechas.dart';

class PanelHistorial extends StatefulWidget {
  final void Function(ChatBoxia) onAbrir;
  final VoidCallback onNuevo;
  const PanelHistorial({
    super.key,
    required this.onAbrir,
    required this.onNuevo,
  });

  @override
  State<PanelHistorial> createState() => _PanelHistorialState();
}

class _PanelHistorialState extends State<PanelHistorial> {
  List<ChatBoxia> _chats = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final chats = await ChatBoxiaStorage.listar();
    if (mounted)
      setState(() {
        _chats = chats;
        _cargando = false;
      });
  }

  Future<void> _borrar(ChatBoxia c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar chat'),
        content: Text(
          '¿Borrar "${c.titulo}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ChatBoxiaStorage.eliminar(c.id);
    _cargar();
  }

  /// Agrupa por etiqueta de fecha conservando el orden.
  Map<String, List<ChatBoxia>> get _agrupado {
    final mapa = <String, List<ChatBoxia>>{};
    for (final c in _chats) {
      mapa.putIfAbsent(etiquetaFecha(c.fecha), () => []).add(c);
    }
    return mapa;
  }

  @override
  Widget build(BuildContext context) {
    final grupos = _agrupado;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scroll) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
              child: Row(
                children: [
                  const Text(
                    'Historial',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onNuevo();
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Nuevo chat'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _chats.isEmpty
                  ? const Center(child: Text('Aún no tienes conversaciones'))
                  : ListView(
                      controller: scroll,
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        for (final entrada in grupos.entries) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                            child: Text(
                              entrada.key,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          for (final c in entrada.value)
                            Dismissible(
                              key: ValueKey(c.id),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (_) async {
                                await _borrar(c);
                                return false; // la lista se recarga sola
                              },
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                color: Colors.red.shade400,
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFF1E3A8A),
                                  child: Icon(
                                    Icons.chat_bubble_outline,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  c.titulo,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${c.mensajes.length} mensajes · '
                                  '${c.fecha.hour.toString().padLeft(2, '0')}:'
                                  '${c.fecha.minute.toString().padLeft(2, '0')}',
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.grey.shade500,
                                  ),
                                  onPressed: () => _borrar(c),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  widget.onAbrir(c);
                                },
                              ),
                            ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
