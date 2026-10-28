import 'dart:convert';
import 'package:s_inventory/models/chat_boxia.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatBoxiaStorage {
  static const _kIndice = 'boxia_chats';
  static const _kActivo = 'boxia_chat_activo';

  static Future<List<String>> _indice() async =>
      (await SharedPreferences.getInstance()).getStringList(_kIndice) ?? [];

  static Future<ChatBoxia?> leer(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('boxia_chat_$id');
    if (raw == null) return null;
    try {
      return ChatBoxia.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  static Future<void> guardar(ChatBoxia chat) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('boxia_chat_${chat.id}', jsonEncode(chat.toJson()));
    final idx = prefs.getStringList(_kIndice) ?? [];
    idx.remove(chat.id);
    idx.insert(0, chat.id);
    await prefs.setStringList(_kIndice, idx);
  }

  static Future<List<ChatBoxia>> listar() async {
    final chats = <ChatBoxia>[];
    for (final id in await _indice()) {
      final c = await leer(id);
      if (c != null) chats.add(c);
    }
    chats.sort((a, b) => b.fecha.compareTo(a.fecha));
    return chats;
  }

  static Future<void> eliminar(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('boxia_chat_$id');
    final idx = prefs.getStringList(_kIndice) ?? [];
    idx.remove(id);
    await prefs.setStringList(_kIndice, idx);
    if (prefs.getString(_kActivo) == id) await prefs.remove(_kActivo);
  }

  static Future<String?> activo() async =>
      (await SharedPreferences.getInstance()).getString(_kActivo);

  static Future<void> setActivo(String id) async =>
      (await SharedPreferences.getInstance()).setString(_kActivo, id);

  // ---- NUEVO: lee el chat activo ----
  static Future<ChatBoxia?> leerActivo() async {
    final id = await activo();
    if (id == null) return null;
    return leer(id);
  }
}