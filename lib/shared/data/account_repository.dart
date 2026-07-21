import 'package:travelmate/core/database/account_dao.dart';
import 'package:travelmate/core/security/password_hasher.dart';
import 'package:travelmate/shared/data/profile_repository.dart' show CipherProvider;

/// Persists the login account and verifies credentials.
///
/// The username is AES-encrypted (mildly sensitive, but needs to be readable),
/// while the password is stored only as a one-way PBKDF2 salted hash — never in
/// a form that can be decrypted back. Depends only on the [AccountDao]
/// abstraction plus injected crypto helpers, so seeding and verification are
/// unit-testable against an in-memory fake DAO.
class AccountRepository {
  AccountRepository({
    required AccountDao dao,
    required CipherProvider cipher,
    PasswordHasher hasher = const PasswordHasher(),
  }) : _dao = dao,
       _cipher = cipher,
       _hasher = hasher;

  final AccountDao _dao;
  final CipherProvider _cipher;
  final PasswordHasher _hasher;

  /// Creates the default account on first run only; a no-op once one exists.
  Future<void> ensureSeeded({
    required String username,
    required String password,
  }) async {
    if (await _dao.countAccounts() > 0) {
      return;
    }

    await _writeAccount(username: username, password: password);
  }

  /// Replaces the stored account with new credentials (used by sign-up). The
  /// single-row account table upserts, so this overwrites any existing account.
  Future<void> createAccount({
    required String username,
    required String password,
  }) {
    return _writeAccount(username: username, password: password);
  }

  Future<void> _writeAccount({
    required String username,
    required String password,
  }) async {
    final cipher = await _cipher();
    final hashed = _hasher.hash(password);

    await _dao.upsertAccountRow({
      'username': cipher.encryptString(username),
      'password_salt': hashed.saltBase64,
      'password_hash': hashed.hashBase64,
      'password_iterations': hashed.iterations,
    });
  }

  /// Returns true when [username] (case-insensitive) matches the stored account
  /// and [password] reproduces the stored hash.
  Future<bool> authenticate(String username, String password) async {
    final row = await _dao.readAccountRow();
    if (row == null) {
      return false;
    }

    final cipher = await _cipher();
    final storedUsername = cipher.decryptString(row['username']! as String);
    if (storedUsername.toLowerCase() != username.trim().toLowerCase()) {
      return false;
    }

    return _hasher.verify(
      password,
      saltBase64: row['password_salt']! as String,
      hashBase64: row['password_hash']! as String,
      iterations: row['password_iterations']! as int,
    );
  }
}
