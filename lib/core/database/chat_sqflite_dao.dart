import 'package:travelmate/core/database/chat_dao.dart';
import 'package:travelmate/core/database/database_helper.dart';

/// `sqflite`-backed [ChatDao]. Thin adapter over the platform database
/// (excluded from coverage); all encryption/mapping/migration logic lives in
/// [ChatRepository], which is tested against an in-memory fake DAO.
class ChatSqfliteDao implements ChatDao {
  ChatSqfliteDao([DatabaseHelper? helper])
    : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  @override
  Future<int> countMessages() async {
    final db = await _helper.database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM ${DatabaseHelper.tableChatMessages}',
    );
    final value = rows.first['count'];
    return value is int ? value : 0;
  }

  @override
  Future<List<Map<String, Object?>>> readAllMessages() async {
    final db = await _helper.database;
    return db.query(DatabaseHelper.tableChatMessages, orderBy: 'id ASC');
  }

  @override
  Future<void> insertMessage(Map<String, Object?> row) async {
    final db = await _helper.database;
    await db.insert(DatabaseHelper.tableChatMessages, row);
  }

  @override
  Future<void> insertMessages(List<Map<String, Object?>> rows) async {
    final db = await _helper.database;
    final batch = db.batch();
    for (final row in rows) {
      batch.insert(DatabaseHelper.tableChatMessages, row);
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> deleteConversation(String mateId) async {
    final db = await _helper.database;
    await db.delete(
      DatabaseHelper.tableChatMessages,
      where: 'mate_id = ?',
      whereArgs: [mateId],
    );
  }
}
