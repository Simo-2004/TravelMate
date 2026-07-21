import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Singleton owner of the app's SQLite connection.
///
/// Keeping a single lazily-opened [Database] instance prevents multiple open
/// handles to the same file. Table creation uses `CREATE TABLE IF NOT EXISTS`
/// so initialization is idempotent; schema growth is handled by bumping
/// [_databaseVersion] and creating any missing tables in `onUpgrade`.
///
/// This class is a thin wrapper over platform plugins (`sqflite`,
/// `path_provider`) and is excluded from coverage — the meaningful logic lives
/// in the repositories, which are tested against fake DAOs.
class DatabaseHelper {
  DatabaseHelper._();

  static const String _databaseName = 'travelmate.db';
  static const int _databaseVersion = 2;

  /// Single-row table; sensitive columns hold AES-GCM base64 payloads.
  static const String tableProfile = 'personal_profile';

  /// Read-only trip catalog rows (public data, stored in plain text).
  static const String tableTrips = 'trips';

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
      onUpgrade: (db, oldVersion, newVersion) => _createTables(db),
    );
  }

  /// Creates every table if missing. Safe to run on both fresh installs
  /// (`onCreate`) and upgrades from an earlier schema (`onUpgrade`).
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

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableTrips (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trip_id TEXT NOT NULL,
        collection TEXT NOT NULL,
        position INTEGER NOT NULL,
        asset TEXT NOT NULL,
        label TEXT NOT NULL,
        schedule_images TEXT NOT NULL,
        tags TEXT NOT NULL,
        destination_title TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');
  }
}
