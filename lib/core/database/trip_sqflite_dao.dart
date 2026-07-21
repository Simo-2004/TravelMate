import 'package:travelmate/core/database/database_helper.dart';
import 'package:travelmate/core/database/trip_dao.dart';

/// `sqflite`-backed [TripDao]. Thin adapter over the platform database
/// (excluded from coverage); all row-mapping/seeding logic lives in
/// [TripRepository], which is tested against an in-memory fake DAO.
class TripSqfliteDao implements TripDao {
  TripSqfliteDao([DatabaseHelper? helper])
    : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  @override
  Future<int> countTrips() async {
    final db = await _helper.database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM ${DatabaseHelper.tableTrips}',
    );
    final value = rows.first['count'];
    return value is int ? value : 0;
  }

  @override
  Future<void> insertTrips(List<Map<String, Object?>> rows) async {
    final db = await _helper.database;
    final batch = db.batch();
    for (final row in rows) {
      batch.insert(DatabaseHelper.tableTrips, row);
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<List<Map<String, Object?>>> readTripsByCollection(
    String collection,
  ) async {
    final db = await _helper.database;
    return db.query(
      DatabaseHelper.tableTrips,
      where: 'collection = ?',
      whereArgs: [collection],
      orderBy: 'position ASC',
    );
  }
}
