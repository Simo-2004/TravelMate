/// Data-access contract for the trip catalog tables.
///
/// [TripRepository] depends on this abstraction rather than on `sqflite`
/// directly, so its seeding and row-mapping logic can be unit-tested against an
/// in-memory fake. The production implementation lives in
/// `trip_sqflite_dao.dart`.
abstract class TripDao {
  /// Total number of trip rows across all collections (used to decide whether
  /// the catalog still needs seeding).
  Future<int> countTrips();

  /// Bulk-inserts trip rows.
  Future<void> insertTrips(List<Map<String, Object?>> rows);

  /// Returns the rows of a single collection (e.g. `trips`, `recents`) ordered
  /// by their stored position.
  Future<List<Map<String, Object?>>> readTripsByCollection(String collection);
}
