import 'package:sqflite/sqflite.dart';

import 'package:travelmate/core/database/database_helper.dart';
import 'package:travelmate/core/database/profile_dao.dart';

/// `sqflite`-backed [ProfileDao]. Thin adapter over the platform database
/// (excluded from coverage); all mapping/encryption logic lives in
/// [ProfileRepository], which is tested against an in-memory fake DAO.
class ProfileSqfliteDao implements ProfileDao {
  ProfileSqfliteDao([DatabaseHelper? helper])
    : _helper = helper ?? DatabaseHelper.instance;

  /// The profile is a singleton record pinned to this primary key.
  static const int profileRowId = 1;

  final DatabaseHelper _helper;

  @override
  Future<Map<String, Object?>?> readProfileRow() async {
    final db = await _helper.database;
    final rows = await db.query(
      DatabaseHelper.tableProfile,
      where: 'id = ?',
      whereArgs: [profileRowId],
      limit: 1,
    );

    return rows.isEmpty ? null : rows.first;
  }

  @override
  Future<void> upsertProfileRow(Map<String, Object?> row) async {
    final db = await _helper.database;
    await db.insert(DatabaseHelper.tableProfile, {
      ...row,
      'id': profileRowId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
