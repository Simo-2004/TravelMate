import 'package:sqflite/sqflite.dart';

import 'package:travelmate/core/database/account_dao.dart';
import 'package:travelmate/core/database/database_helper.dart';

/// `sqflite`-backed [AccountDao]. Thin adapter over the platform database
/// (excluded from coverage); all hashing/encryption/verification logic lives in
/// [AccountRepository], which is tested against an in-memory fake DAO.
class AccountSqfliteDao implements AccountDao {
  AccountSqfliteDao([DatabaseHelper? helper])
    : _helper = helper ?? DatabaseHelper.instance;

  /// The account is a singleton record pinned to this primary key.
  static const int accountRowId = 1;

  final DatabaseHelper _helper;

  @override
  Future<int> countAccounts() async {
    final db = await _helper.database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM ${DatabaseHelper.tableAccount}',
    );
    final value = rows.first['count'];
    return value is int ? value : 0;
  }

  @override
  Future<Map<String, Object?>?> readAccountRow() async {
    final db = await _helper.database;
    final rows = await db.query(
      DatabaseHelper.tableAccount,
      where: 'id = ?',
      whereArgs: [accountRowId],
      limit: 1,
    );

    return rows.isEmpty ? null : rows.first;
  }

  @override
  Future<void> upsertAccountRow(Map<String, Object?> row) async {
    final db = await _helper.database;
    await db.insert(
      DatabaseHelper.tableAccount,
      {...row, 'id': accountRowId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
