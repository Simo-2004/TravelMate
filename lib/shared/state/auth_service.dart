import 'package:flutter/foundation.dart';

import 'package:travelmate/core/database/account_sqflite_dao.dart';
import 'package:travelmate/core/security/aes_cipher.dart';
import 'package:travelmate/core/security/flutter_secure_key_store.dart';
import 'package:travelmate/core/security/profile_key_provider.dart';
import 'package:travelmate/shared/data/account_repository.dart';

/// Owns the login account and answers credential checks for the login screen.
///
/// On startup it seeds a default account (encrypted username + salted password
/// hash) into SQLite if none exists. The default credentials below are what the
/// user types on the login screen.
class AuthService {
  AuthService._({AccountRepository? repository})
    : _repository = repository ?? _buildProductionRepository();

  /// Default seeded credentials — enter these on the login screen.
  static const String defaultUsername = 'alessia';
  static const String defaultPassword = 'travelmate';

  AccountRepository _repository;
  bool _initialized = false;

  static final AuthService instance = AuthService._();

  /// Seeds the default account on first run. Safe to call more than once.
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
    await _repository.ensureSeeded(
      username: defaultUsername,
      password: defaultPassword,
    );
  }

  /// Verifies a login attempt against the stored account.
  Future<bool> authenticate(String username, String password) {
    return _repository.authenticate(username, password);
  }

  static AccountRepository _buildProductionRepository() {
    final keyProvider = ProfileKeyProvider(const FlutterSecureKeyStore());

    return AccountRepository(
      dao: AccountSqfliteDao(),
      cipher: () async => AesCipher(await keyProvider.getOrCreateKey()),
    );
  }

  /// Test-only seam: swaps the backing repository (typically over a fake DAO)
  /// so login flows can be exercised without SQLite / secure storage.
  @visibleForTesting
  void debugSetRepository(AccountRepository repository) {
    _repository = repository;
    _initialized = false;
  }
}
