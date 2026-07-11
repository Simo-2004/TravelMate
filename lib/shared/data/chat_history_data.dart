import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelmate/shared/models/chat_message.dart';

class ChatHistoryData {
  static const String _storageKey = 'chat_history_v1';

  const ChatHistoryData();

  Future<Map<String, List<ChatMessage>>> readAll() async {
    final preferences = await SharedPreferences.getInstance();
    final serialized = preferences.getString(_storageKey);

    if (serialized == null || serialized.isEmpty) {
      return const {};
    }

    try {
      final decoded = jsonDecode(serialized);
      if (decoded is! Map) {
        return const {};
      }

      final conversations = <String, List<ChatMessage>>{};
      for (final entry in decoded.entries) {
        final rawMessages = entry.value;
        if (rawMessages is! List) {
          continue;
        }

        conversations[entry.key.toString()] = rawMessages
            .whereType<Map>()
            .map(
              (item) => ChatMessage.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(growable: false);
      }

      return conversations;
    } catch (_) {
      return const {};
    }
  }

  Future<void> writeAll(Map<String, List<ChatMessage>> conversations) async {
    final preferences = await SharedPreferences.getInstance();
    final serializable = conversations.map(
      (mateId, messages) => MapEntry(
        mateId,
        messages.map((message) => message.toJson()).toList(growable: false),
      ),
    );

    await preferences.setString(_storageKey, jsonEncode(serializable));
  }
}
