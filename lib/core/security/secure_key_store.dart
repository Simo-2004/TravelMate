/// Minimal key/value contract for at-rest secret storage.
///
/// Kept as an interface so the encryption layer never depends directly on a
/// platform plugin: production uses the OS keystore (see
/// `flutter_secure_key_store.dart`), while tests use an in-memory fake. This
/// keeps [ProfileKeyProvider] and everything above it fully unit-testable.
abstract class SecureKeyStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);
}
