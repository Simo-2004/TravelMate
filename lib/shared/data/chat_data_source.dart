import 'package:travelmate/shared/models/chat_message.dart';

/// Read/write contract for chat history, keyed by mate id.
///
/// [ChatStore] depends on this abstraction, so its backing store can change
/// (SharedPreferences → SQLite) without touching the store or any screen.
abstract class ChatDataSource {
  /// Returns every persisted conversation, keyed by mate id.
  Future<Map<String, List<ChatMessage>>> readAll();

  /// Persists a single new message appended to [mateId]'s conversation.
  Future<void> appendMessage(String mateId, ChatMessage message);

  /// Deletes every persisted message for [mateId].
  Future<void> clearConversation(String mateId);
}
