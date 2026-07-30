/// Integration testing — the account persistence stack.
///
/// AccountRepository sits on top of two different primitives at once: the AES
/// cipher (for the username, which has to be readable again) and the PBKDF2
/// hasher (for the password, which must not be). These tests check that the
/// combination behaves correctly end to end against a fake DAO.
library;

import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  group('seeding', () {
    test('seeds an encrypted username and hashed password once', () async {
      final dao = FakeAccountDao();
      final repository = testAccountRepository(dao);

      await repository.ensureSeeded(
        username: 'Alessia',
        password: 'travelmate',
      );
      final row = dao.row!;

      expect(row['username'], isNot('Alessia'));
      expect(row['password_hash'], isNot('travelmate'));
      expect(row['password_salt'], isNotNull);
      expect(row['password_iterations'], isA<int>());

      // A second seed keeps the original row.
      await repository.ensureSeeded(username: 'Other', password: 'nope');
      expect(await dao.countAccounts(), 1);
      expect(await repository.authenticate('Alessia', 'travelmate'), isTrue);
    });
  });

  group('authentication', () {
    test('accepts valid credentials, matching the username loosely', () async {
      final repository = testAccountRepository(FakeAccountDao());
      await repository.ensureSeeded(
        username: 'alessia',
        password: 'travelmate',
      );

      expect(await repository.authenticate('alessia', 'travelmate'), isTrue);
      expect(await repository.authenticate('  ALESSIA ', 'travelmate'), isTrue);
    });

    test(
      'rejects a wrong password, wrong username or missing account',
      () async {
        final repository = testAccountRepository(FakeAccountDao());

        // No account seeded yet.
        expect(await repository.authenticate('alessia', 'travelmate'), isFalse);

        await repository.ensureSeeded(
          username: 'alessia',
          password: 'travelmate',
        );
        expect(await repository.authenticate('alessia', 'wrong'), isFalse);
        expect(await repository.authenticate('bob', 'travelmate'), isFalse);
      },
    );

    test('the password is matched exactly — case and spacing count', () async {
      final repository = testAccountRepository(FakeAccountDao());
      await repository.ensureSeeded(username: 'a_user', password: 'travelmate');

      expect(await repository.authenticate('a_user', 'TravelMate'), isFalse);
      expect(await repository.authenticate('a_user', ' travelmate'), isFalse);
      expect(await repository.authenticate('a_user', 'travelmate '), isFalse);
    });

    test('rejects an empty password against a real account', () async {
      final repository = testAccountRepository(FakeAccountDao());
      await repository.ensureSeeded(username: 'a_user', password: 'travelmate');

      expect(await repository.authenticate('a_user', ''), isFalse);
    });
  });

  group('sign-up', () {
    test('createAccount overwrites the existing account', () async {
      final repository = testAccountRepository(FakeAccountDao());
      await repository.ensureSeeded(
        username: 'alessia',
        password: 'travelmate',
      );

      await repository.createAccount(username: 'bob', password: 'password1');

      expect(await repository.authenticate('bob', 'password1'), isTrue);
      // Old credentials no longer work.
      expect(await repository.authenticate('alessia', 'travelmate'), isFalse);
    });

    test('createAccount keeps the table single-row', () async {
      final dao = FakeAccountDao();
      final repository = testAccountRepository(dao);

      await repository.createAccount(username: 'one', password: 'password1');
      await repository.createAccount(username: 'two', password: 'password2');

      expect(await dao.countAccounts(), 1);
      expect(await repository.authenticate('two', 'password2'), isTrue);
    });

    test('createAccount works on a completely empty store', () async {
      final repository = testAccountRepository(FakeAccountDao());

      await repository.createAccount(username: 'fresh', password: 'password1');

      expect(await repository.authenticate('fresh', 'password1'), isTrue);
    });

    test('two accounts with the same password get different hashes', () async {
      final firstDao = FakeAccountDao();
      final secondDao = FakeAccountDao();

      await testAccountRepository(
        firstDao,
      ).createAccount(username: 'one', password: 'samepassword');
      await testAccountRepository(
        secondDao,
      ).createAccount(username: 'two', password: 'samepassword');

      expect(
        firstDao.row!['password_hash'],
        isNot(secondDao.row!['password_hash']),
        reason: 'per-account salt must make identical passwords look different',
      );
    });
  });
}
