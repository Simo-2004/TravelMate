/// In-memory test doubles for every persistence and platform boundary in the
/// app.
///
/// The production code depends on abstractions ([ProfileDao], [TripDao],
/// [ChatDao], [AccountDao], [SecureKeyStore], [ProfileDataSource],
/// [ChatDataSource]) rather than on `sqflite` / `flutter_secure_storage`
/// directly. That is what makes every level below "system" runnable in the
/// plain Dart test VM: the fakes here stand in for the native plugins, which
/// would otherwise require a device or emulator.
library;

import 'package:encrypt/encrypt.dart' as enc;

import 'package:travelmate/core/database/account_dao.dart';
import 'package:travelmate/core/database/chat_dao.dart';
import 'package:travelmate/core/database/profile_dao.dart';
import 'package:travelmate/core/database/trip_dao.dart';
import 'package:travelmate/core/security/aes_cipher.dart';
import 'package:travelmate/core/security/password_hasher.dart';
import 'package:travelmate/core/security/secure_key_store.dart';
import 'package:travelmate/shared/data/account_repository.dart';
import 'package:travelmate/shared/data/chat_data_source.dart';
import 'package:travelmate/shared/data/chat_repository.dart';
import 'package:travelmate/shared/data/profile_data_source.dart';
import 'package:travelmate/shared/data/profile_repository.dart';
import 'package:travelmate/shared/models/chat_message.dart';
import 'package:travelmate/shared/models/personal_profile.dart';

/// PBKDF2 rounds used throughout the suite. Production uses far more; tests
/// only need the algorithm to be exercised, not to be slow.
const PasswordHasher testHasher = PasswordHasher(iterations: 1000);

/// A 32-byte (AES-256) key that is the *same* on every call, so ciphers built
/// at different points in a test can read each other's output — mirroring
/// production, where the key provider memoizes one key for the process.
const String _fixedTestKey = 'travelmate-test-key-32-bytes!!!!';

/// A cipher over [_fixedTestKey].
AesCipher testCipher() => AesCipher(enc.Key.fromUtf8(_fixedTestKey));

/// A cipher over a *different*, randomly generated key — for asserting that
/// data encrypted under one key cannot be read under another.
AesCipher foreignCipher() => AesCipher(enc.Key.fromSecureRandom(32));

// ---------------------------------------------------------------------------
// DAO fakes
// ---------------------------------------------------------------------------

/// In-memory [ProfileDao] holding the single profile row.
class FakeProfileDao implements ProfileDao {
  /// The stored row, or null when nothing has been written yet. Exposed so
  /// tests can assert on the *encrypted* column values directly.
  Map<String, Object?>? row;

  @override
  Future<Map<String, Object?>?> readProfileRow() async => row;

  @override
  Future<void> upsertProfileRow(Map<String, Object?> newRow) async {
    row = Map<String, Object?>.from(newRow);
  }
}

/// In-memory [TripDao] over a plain list of rows.
class FakeTripDao implements TripDao {
  /// Every inserted row, in insertion order.
  final List<Map<String, Object?>> rows = [];

  @override
  Future<int> countTrips() async => rows.length;

  @override
  Future<void> insertTrips(List<Map<String, Object?>> newRows) async {
    rows.addAll(newRows.map(Map<String, Object?>.from));
  }

  @override
  Future<List<Map<String, Object?>>> readTripsByCollection(
    String collection,
  ) async {
    return rows.where((row) => row['collection'] == collection).toList()..sort(
      (a, b) => (a['position']! as int).compareTo(b['position']! as int),
    );
  }
}

/// In-memory [ChatDao] over a plain list of message rows.
class FakeChatDao implements ChatDao {
  /// Every inserted row, in insertion order. Exposed so tests can assert on
  /// the *encrypted* text column directly.
  final List<Map<String, Object?>> rows = [];

  @override
  Future<int> countMessages() async => rows.length;

  @override
  Future<List<Map<String, Object?>>> readAllMessages() async =>
      List<Map<String, Object?>>.from(rows);

  @override
  Future<void> insertMessage(Map<String, Object?> row) async {
    rows.add(Map<String, Object?>.from(row));
  }

  @override
  Future<void> insertMessages(List<Map<String, Object?>> newRows) async {
    rows.addAll(newRows.map(Map<String, Object?>.from));
  }

  @override
  Future<void> deleteConversation(String mateId) async {
    rows.removeWhere((row) => row['mate_id'] == mateId);
  }
}

/// In-memory [AccountDao] holding the single account row.
class FakeAccountDao implements AccountDao {
  Map<String, Object?>? _row;

  /// The stored row, or null before the first write. Exposed so tests can
  /// assert that no credential is recoverable from what was persisted.
  Map<String, Object?>? get row => _row;

  @override
  Future<int> countAccounts() async => _row == null ? 0 : 1;

  @override
  Future<Map<String, Object?>?> readAccountRow() async => _row;

  @override
  Future<void> upsertAccountRow(Map<String, Object?> row) async {
    _row = Map<String, Object?>.from(row);
  }
}

/// In-memory [SecureKeyStore] that counts writes, so tests can prove the AES
/// key is generated once and then reused rather than regenerated.
class FakeSecureKeyStore implements SecureKeyStore {
  /// Everything written so far, keyed exactly as the production store would.
  final Map<String, String> values = {};

  /// How many times [write] was called.
  int writes = 0;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
    writes++;
  }
}

// ---------------------------------------------------------------------------
// Data-source fakes
// ---------------------------------------------------------------------------

/// In-memory [ProfileDataSource], so exercising the profile store never
/// reaches the SQLite / secure-storage platform plugins.
class InMemoryProfileData implements ProfileDataSource {
  InMemoryProfileData([this._profile = PersonalProfile.defaultProfile]);

  PersonalProfile _profile;

  @override
  Future<PersonalProfile> read() async => _profile;

  @override
  Future<void> write(PersonalProfile profile) async => _profile = profile;
}

/// In-memory [ChatDataSource], so exercising the chat store never reaches the
/// SQLite platform plugin. Optionally pre-seeded to simulate history persisted
/// by an earlier app session.
class InMemoryChatData implements ChatDataSource {
  InMemoryChatData([Map<String, List<ChatMessage>>? initial]) {
    if (initial != null) {
      initial.forEach((mateId, messages) {
        _conversations[mateId] = List<ChatMessage>.from(messages);
      });
    }
  }

  final Map<String, List<ChatMessage>> _conversations = {};

  @override
  Future<Map<String, List<ChatMessage>>> readAll() async =>
      Map<String, List<ChatMessage>>.from(_conversations);

  @override
  Future<void> appendMessage(String mateId, ChatMessage message) async {
    _conversations[mateId] = [...?_conversations[mateId], message];
  }

  @override
  Future<void> clearConversation(String mateId) async {
    _conversations.remove(mateId);
  }
}

// ---------------------------------------------------------------------------
// Repository factories
// ---------------------------------------------------------------------------

/// Builds a [ProfileRepository] over [dao] with the shared test cipher.
ProfileRepository testProfileRepository(FakeProfileDao dao) {
  final cipher = testCipher();
  return ProfileRepository(dao: dao, cipher: () async => cipher);
}

/// Builds a [ChatRepository] over [dao] with the shared test cipher.
ChatRepository testChatRepository(FakeChatDao dao) {
  final cipher = testCipher();
  return ChatRepository(dao: dao, cipher: () async => cipher);
}

/// Builds an [AccountRepository] over [dao] with the shared test cipher and a
/// deliberately cheap PBKDF2 cost.
AccountRepository testAccountRepository(FakeAccountDao dao) {
  final cipher = testCipher();
  return AccountRepository(
    dao: dao,
    cipher: () async => cipher,
    hasher: testHasher,
  );
}
