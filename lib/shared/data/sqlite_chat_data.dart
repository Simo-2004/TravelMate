import 'package:travelmate/core/database/chat_sqflite_dao.dart';
import 'package:travelmate/core/security/aes_cipher.dart';
import 'package:travelmate/core/security/flutter_secure_key_store.dart';
import 'package:travelmate/core/security/profile_key_provider.dart';
import 'package:travelmate/shared/data/chat_data_source.dart';
import 'package:travelmate/shared/data/chat_history_data.dart';
import 'package:travelmate/shared/data/chat_repository.dart';
import 'package:travelmate/shared/models/chat_message.dart';

/// SQLite-backed [ChatDataSource]: the current persistence layer for chat
/// history.
///
/// On first use it transparently migrates any history saved by a previous
/// (SharedPreferences) app version into the encrypted database, so upgrading
/// users keep their conversations. Reuses the same AES key/provider as the
/// personal profile.
///
/// The database and secret-store wiring is injected, so this class (including
/// the migration path) is unit-testable with fakes.
class SqliteChatData implements ChatDataSource {
  SqliteChatData({
    required ChatRepository repository,
    ChatHistoryData legacy = const ChatHistoryData(),
  }) : _repository = repository,
       _legacy = legacy;

  /// Production wiring: encrypted sqflite repository + OS-keystore-held key.
  factory SqliteChatData.production() {
    final keyProvider = ProfileKeyProvider(const FlutterSecureKeyStore());

    return SqliteChatData(
      repository: ChatRepository(
        dao: ChatSqfliteDao(),
        cipher: () async => AesCipher(await keyProvider.getOrCreateKey()),
      ),
    );
  }

  final ChatRepository _repository;
  final ChatHistoryData _legacy;
  bool _migrationChecked = false;

  @override
  Future<Map<String, List<ChatMessage>>> readAll() async {
    await _migrateIfNeeded();
    return _repository.readAllConversations();
  }

  Future<void> _migrateIfNeeded() async {
    if (_migrationChecked) {
      return;
    }
    _migrationChecked = true;

    if (await _repository.countMessages() > 0) {
      return;
    }

    final legacyConversations = await _legacy.readAll();
    await _repository.appendAll(legacyConversations);
  }

  @override
  Future<void> appendMessage(String mateId, ChatMessage message) {
    return _repository.appendMessage(mateId, message);
  }

  @override
  Future<void> clearConversation(String mateId) {
    return _repository.clearConversation(mateId);
  }
}
