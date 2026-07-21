import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Singleton owner of the app's SQLite connection.
///
/// Keeping a single lazily-opened [Database] instance prevents multiple open
/// handles to the same file. Table creation uses `CREATE TABLE IF NOT EXISTS`
/// so initialization is idempotent and safe to call repeatedly.
///
/// This class is a thin wrapper over platform plugins (`sqflite`,
/// `path_provider`) and is excluded from coverage — the meaningful logic lives
/// in [ProfileRepository], which is tested against a fake [ProfileDao].
class DatabaseHelper {
  DatabaseHelper._();

  static const String _databaseName = 'travelmate.db';
  static const int _databaseVersion = 1;

  /// Single-row table; sensitive columns hold AES-GCM base64 payloads.
  static const String tableProfile = 'personal_profile';

  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    return _database ??= await _open();
  }

  Future<Database> _open() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final path = p.join(documentsDir.path, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) => _createTables(db),
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableProfile (
        id INTEGER PRIMARY KEY,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        description TEXT NOT NULL,
        photo_path TEXT NOT NULL,
        interest_tags TEXT NOT NULL,
        trip_tags TEXT NOT NULL
      )
    ''');
  }
}
