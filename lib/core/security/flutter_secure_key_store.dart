import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:travelmate/core/security/secure_key_store.dart';

/// [SecureKeyStore] backed by the OS keystore/keychain via
/// `flutter_secure_storage`. Thin platform adapter (excluded from coverage);
/// the key lifecycle logic it feeds lives in [ProfileKeyProvider].
class FlutterSecureKeyStore implements SecureKeyStore {
  const FlutterSecureKeyStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}
