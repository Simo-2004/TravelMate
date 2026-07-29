import 'package:travelmate/core/database/chat_dao.dart';
import 'package:travelmate/core/security/aes_cipher.dart';
import 'package:travelmate/shared/data/profile_repository.dart'
    show CipherProvider;
import 'package:travelmate/shared/models/chat_message.dart';

/// Persists chat messages to SQLite, encrypting only the message text.
///
/// `mate_id`, `is_from_me`, `sent_at` and `attached_trip_id` stay plain —
/// they're structural/query columns, not conversation content, mirroring how
/// the profile and account tables keep ids/flags plain and encrypt only the
/// readable fields. Depends only on the [ChatDao] abstraction plus an
/// injected [CipherProvider], so mapping/encryption/grouping are fully
/// unit-testable against an in-memory fake DAO.
class ChatRepository {
  ChatRepository({required ChatDao dao, required CipherProvider cipher})
    : _dao = dao,
      _cipher = cipher;

  final ChatDao _dao;
  final CipherProvider _cipher;

  Future<int> countMessages() => _dao.countMessages();

  /// Loads every message, grouped by mate id, oldest-first within each
  /// conversation (messages are always appended in order for a given mate,
  /// so the DAO's insertion-order read keeps each group chronological).
  Future<Map<String, List<ChatMessage>>> readAllConversations() async {
    final rows = await _dao.readAllMessages();
    if (rows.isEmpty) {
      return const {};
    }

    final cipher = await _cipher();
    final conversations = <String, List<ChatMessage>>{};

    for (final row in rows) {
      final mateId = row['mate_id']! as String;
      conversations
          .putIfAbsent(mateId, () => <ChatMessage>[])
          .add(_fromRow(row, cipher));
    }

    return conversations.map(
      (mateId, messages) =>
          MapEntry(mateId, List<ChatMessage>.unmodifiable(messages)),
    );
  }

  Future<void> appendMessage(String mateId, ChatMessage message) async {
    final cipher = await _cipher();
    await _dao.insertMessage(_toRow(mateId, message, cipher));
  }

  /// Bulk-inserts every message in [conversations] (used for one-time legacy
  /// migration, where a full history import benefits from a single batch).
  Future<void> appendAll(Map<String, List<ChatMessage>> conversations) async {
    if (conversations.isEmpty) {
      return;
    }

    final cipher = await _cipher();
    final rows = <Map<String, Object?>>[
      for (final entry in conversations.entries)
        for (final message in entry.value) _toRow(entry.key, message, cipher),
    ];

    if (rows.isNotEmpty) {
      await _dao.insertMessages(rows);
    }
  }

  Future<void> clearConversation(String mateId) {
    return _dao.deleteConversation(mateId);
  }

  Map<String, Object?> _toRow(
    String mateId,
    ChatMessage message,
    AesCipher cipher,
  ) {
    return {
      'mate_id': mateId,
      'message_id': message.id,
      'text': cipher.encryptString(message.text),
      'is_from_me': message.isFromMe ? 1 : 0,
      'sent_at': message.sentAt.toIso8601String(),
      'attached_trip_id': message.attachedTripId,
    };
  }

  ChatMessage _fromRow(Map<String, Object?> row, AesCipher cipher) {
    final sentAtRaw = row['sent_at']! as String;

    return ChatMessage(
      id: row['message_id']! as String,
      text: cipher.decryptString(row['text']! as String),
      isFromMe: (row['is_from_me']! as int) != 0,
      sentAt: DateTime.tryParse(sentAtRaw) ?? DateTime.now(),
      attachedTripId: row['attached_trip_id'] as String?,
    );
  }
}
