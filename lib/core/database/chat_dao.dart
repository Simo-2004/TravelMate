/// Data-access contract for chat message rows.
///
/// [ChatRepository] depends on this abstraction rather than on `sqflite`
/// directly, so its encryption/mapping/migration logic is unit-testable
/// against an in-memory fake. The production implementation lives in
/// `chat_sqflite_dao.dart`.
abstract class ChatDao {
  /// Total number of stored messages across every conversation (used to
  /// decide whether legacy history still needs to be migrated in).
  Future<int> countMessages();

  /// Returns every message row, ordered oldest-first.
  Future<List<Map<String, Object?>>> readAllMessages();

  /// Appends a single message row.
  Future<void> insertMessage(Map<String, Object?> row);

  /// Bulk-inserts message rows (used for one-time legacy migration).
  Future<void> insertMessages(List<Map<String, Object?>> rows);

  /// Deletes every message belonging to [mateId].
  Future<void> deleteConversation(String mateId);
}
