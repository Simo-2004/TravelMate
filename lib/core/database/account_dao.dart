/// Data-access contract for the single-row login account record.
///
/// [AccountRepository] depends on this abstraction rather than on `sqflite`
/// directly, so its hashing/encryption/verification logic is unit-testable
/// against an in-memory fake. The production implementation lives in
/// `account_sqflite_dao.dart`.
abstract class AccountDao {
  /// Number of stored accounts (used to decide whether to seed the default).
  Future<int> countAccounts();

  /// Returns the stored account row, or null when none exists.
  Future<Map<String, Object?>?> readAccountRow();

  /// Inserts or replaces the account row.
  Future<void> upsertAccountRow(Map<String, Object?> row);
}
