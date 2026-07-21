import 'package:encrypt/encrypt.dart';

import 'package:travelmate/core/security/secure_key_store.dart';

/// Resolves the AES key used for profile field encryption, generating one on
/// first use and persisting it in the injected [SecureKeyStore].
///
/// The generated 256-bit key never leaves secure storage in plaintext form and
/// is created with a cryptographically secure RNG. Depends only on the
/// [SecureKeyStore] abstraction, so the get-or-create logic is unit-testable
/// with an in-memory fake.
class ProfileKeyProvider {
  ProfileKeyProvider(this._store);

  static const String _keyName = 'profile_aes_key_v1';
  static const int _keyLengthBytes = 32; // AES-256

  final SecureKeyStore _store;

  Key? _cached;

  /// Returns the persisted key, creating and storing a new one if absent.
  /// The result is memoized so repeated encrypt/decrypt calls avoid extra
  /// secure-storage reads.
  Future<Key> getOrCreateKey() async {
    final cached = _cached;
    if (cached != null) {
      return cached;
    }

    final existing = await _store.read(_keyName);
    if (existing != null && existing.isNotEmpty) {
      return _cached = Key.fromBase64(existing);
    }

    final generated = Key.fromSecureRandom(_keyLengthBytes);
    await _store.write(_keyName, generated.base64);
    return _cached = generated;
  }
}
