/// Data-access contract for the single-row personal profile record.
///
/// The [ProfileRepository] depends on this abstraction rather than on `sqflite`
/// directly, so its mapping/encryption/migration logic can be exercised
/// against an in-memory fake in `flutter test` without a native SQLite engine.
/// The production implementation lives in `profile_sqflite_dao.dart`.
abstract class ProfileDao {
  /// Returns the stored profile row, or null when the table is empty.
  Future<Map<String, Object?>?> readProfileRow();

  /// Inserts or replaces the profile row.
  Future<void> upsertProfileRow(Map<String, Object?> row);
}
