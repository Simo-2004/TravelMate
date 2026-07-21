import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/core/security/aes_cipher.dart';
import 'package:travelmate/core/security/password_hasher.dart';
import 'package:travelmate/shared/data/account_repository.dart';
import 'package:travelmate/shared/state/auth_service.dart';

import 'helpers/test_harness.dart';

AccountRepository _repository(FakeAccountDao dao) {
  final cipher = AesCipher(enc.Key.fromLength(32));
  return AccountRepository(
    dao: dao,
    cipher: () async => cipher,
    hasher: const PasswordHasher(iterations: 1000),
  );
}

void main() {
  group('PasswordHasher', () {
    const hasher = PasswordHasher(iterations: 1000);

    test('verifies the correct password and rejects a wrong one', () {
      final hashed = hasher.hash('s3cret');

      expect(
        hasher.verify(
          's3cret',
          saltBase64: hashed.saltBase64,
          hashBase64: hashed.hashBase64,
          iterations: hashed.iterations,
        ),
        isTrue,
      );
      expect(
        hasher.verify(
          'wrong',
          saltBase64: hashed.saltBase64,
          hashBase64: hashed.hashBase64,
          iterations: hashed.iterations,
        ),
        isFalse,
      );
    });

    test('uses a fresh random salt per hash', () {
      final a = hasher.hash('same');
      final b = hasher.hash('same');

      expect(a.saltBase64, isNot(b.saltBase64));
      expect(a.hashBase64, isNot(b.hashBase64));
    });

    test('is deterministic for a fixed salt', () {
      final salt = Uint8List.fromList(List<int>.filled(16, 7));

      final a = hasher.hash('pw', salt: salt);
      final b = hasher.hash('pw', salt: salt);

      expect(a.hashBase64, b.hashBase64);
    });
  });

  group('AccountRepository', () {
    test('seeds an encrypted username and hashed password once', () async {
      final dao = FakeAccountDao();
      final repository = _repository(dao);

      await repository.ensureSeeded(username: 'Alessia', password: 'travelmate');
      final row = await dao.readAccountRow();

      // Username is encrypted, password is never stored in plaintext.
      expect(row!['username'], isNot('Alessia'));
      expect(row['password_hash'], isNot('travelmate'));
      expect(row['password_salt'], isNotNull);

      // Second seed is a no-op (keeps the original row).
      await repository.ensureSeeded(username: 'Other', password: 'nope');
      expect(await dao.countAccounts(), 1);
    });

    test('authenticates valid credentials, case-insensitive username',
        () async {
      final repository = _repository(FakeAccountDao());
      await repository.ensureSeeded(username: 'alessia', password: 'travelmate');

      expect(await repository.authenticate('alessia', 'travelmate'), isTrue);
      expect(await repository.authenticate('  ALESSIA ', 'travelmate'), isTrue);
    });

    test('rejects a wrong password, wrong username, or missing account',
        () async {
      final dao = FakeAccountDao();
      final repository = _repository(dao);

      // No account seeded yet.
      expect(await repository.authenticate('alessia', 'travelmate'), isFalse);

      await repository.ensureSeeded(username: 'alessia', password: 'travelmate');
      expect(await repository.authenticate('alessia', 'wrong'), isFalse);
      expect(await repository.authenticate('bob', 'travelmate'), isFalse);
    });

    test('createAccount overwrites the existing account', () async {
      final repository = _repository(FakeAccountDao());
      await repository.ensureSeeded(username: 'alessia', password: 'travelmate');

      await repository.createAccount(username: 'bob', password: 'password1');

      expect(await repository.authenticate('bob', 'password1'), isTrue);
      // Old credentials no longer work.
      expect(await repository.authenticate('alessia', 'travelmate'), isFalse);
    });
  });

  group('AuthService', () {
    test('initialize seeds the default account and authenticates', () async {
      AuthService.instance.debugSetRepository(_repository(FakeAccountDao()));

      await AuthService.instance.initialize();
      await AuthService.instance.initialize(); // idempotent

      expect(
        await AuthService.instance.authenticate(
          AuthService.defaultUsername,
          AuthService.defaultPassword,
        ),
        isTrue,
      );
      expect(
        await AuthService.instance.authenticate(
          AuthService.defaultUsername,
          'bad',
        ),
        isFalse,
      );
    });

    test('createAccount replaces the credentials used by authenticate',
        () async {
      AuthService.instance.debugSetRepository(_repository(FakeAccountDao()));
      await AuthService.instance.initialize();

      await AuthService.instance.createAccount('newbie', 'password1');

      expect(
        await AuthService.instance.authenticate('newbie', 'password1'),
        isTrue,
      );
    });
  });
}
