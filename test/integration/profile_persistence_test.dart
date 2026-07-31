/// Integration testing — the profile persistence stack.
///
/// Unit tests cover each piece alone; these tests wire the layers together and
/// check the interfaces *between* them:
///
///   ProfileKeyProvider -> AesCipher -> ProfileRepository -> ProfileDao
///                                            ^
///                                    SqliteProfileData (+ legacy migration)
///
/// Only the bottom edge is faked (the DAO and the key store, which are the
/// SQLite and keychain plugins).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:travelmate/core/security/profile_key_provider.dart';
import 'package:travelmate/shared/data/personal_profile_data.dart';
import 'package:travelmate/shared/data/sqlite_profile_data.dart';
import 'package:travelmate/shared/models/personal_profile.dart';

import '../helpers/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ProfileKeyProvider over the key store', () {
    test('generates and stores a 256-bit key on first use', () async {
      final store = FakeSecureKeyStore();

      final key = await ProfileKeyProvider(store).getOrCreateKey();

      expect(key.bytes.length, 32);
      expect(store.writes, 1);
      expect(store.values.values.single, key.base64);
    });

    test('reuses the stored key across instances and memoizes it', () async {
      final store = FakeSecureKeyStore();
      final first = await ProfileKeyProvider(store).getOrCreateKey();

      final reloaded = ProfileKeyProvider(store);
      final second = await reloaded.getOrCreateKey();
      final third = await reloaded.getOrCreateKey();

      expect(second.base64, first.base64);
      expect(third.base64, first.base64);
      expect(store.writes, 1, reason: 'the key must never be regenerated');
    });
  });

  group('ProfileRepository over the DAO', () {
    test('returns null when nothing is stored', () async {
      expect(
        await testProfileRepository(FakeProfileDao()).readProfile(),
        isNull,
      );
    });

    test('encrypts fields on write and restores them on read', () async {
      final dao = FakeProfileDao();
      final repository = testProfileRepository(dao);
      const profile = PersonalProfile(
        firstName: 'Ada',
        lastName: 'Byron',
        description: 'Analytical traveler.',
        photoAsset: '/data/app/profile_1.png',
        interestTags: <String>['Museums', 'Trains'],
        tripTags: <String>['City break'],
      );

      await repository.writeProfile(profile);

      // Stored columns must not contain the plaintext.
      expect(dao.row!['first_name'], isNot('Ada'));
      expect(dao.row!['description'], isNot(contains('Analytical')));

      final restored = await repository.readProfile();
      expect(restored!.firstName, 'Ada');
      expect(restored.lastName, 'Byron');
      expect(restored.description, 'Analytical traveler.');
      expect(restored.photoAsset, '/data/app/profile_1.png');
      expect(restored.interestTags, ['Museums', 'Trains']);
      expect(restored.tripTags, ['City break']);
    });

    test(
      'a second write replaces the stored row rather than appending',
      () async {
        final dao = FakeProfileDao();
        final repository = testProfileRepository(dao);

        await repository.writeProfile(
          PersonalProfile.defaultProfile.copyWith(firstName: 'First'),
        );
        await repository.writeProfile(
          PersonalProfile.defaultProfile.copyWith(firstName: 'Second'),
        );

        expect((await repository.readProfile())!.firstName, 'Second');
      },
    );

    test('round-trips a profile with empty tag lists', () async {
      final repository = testProfileRepository(FakeProfileDao());

      await repository.writeProfile(
        PersonalProfile.defaultProfile.copyWith(
          interestTags: const [],
          tripTags: const [],
        ),
      );

      final restored = await repository.readProfile();
      expect(restored!.interestTags, isEmpty);
      expect(restored.tripTags, isEmpty);
    });
  });

  group('SqliteProfileData', () {
    SqliteProfileData build(FakeProfileDao dao) {
      return SqliteProfileData(repository: testProfileRepository(dao));
    }

    test('falls back to the default profile when nothing exists', () async {
      final profile = await build(FakeProfileDao()).read();

      expect(profile.firstName, PersonalProfile.defaultProfile.firstName);
    });

    test('migrates a legacy SharedPreferences profile into the db', () async {
      await const PersonalProfileData().write(
        PersonalProfile.defaultProfile.copyWith(firstName: 'Legacy'),
      );

      final dao = FakeProfileDao();
      final data = build(dao);

      final migrated = await data.read();
      expect(migrated.firstName, 'Legacy');
      expect(dao.row, isNotNull, reason: 'written through to the encrypted db');

      // A subsequent read now comes from the db, not the legacy store.
      expect((await data.read()).firstName, 'Legacy');
    });

    test('persists writes through the repository', () async {
      final data = build(FakeProfileDao());

      await data.write(
        PersonalProfile.defaultProfile.copyWith(firstName: 'Saved'),
      );

      expect((await data.read()).firstName, 'Saved');
    });

    test('a write after migration wins over the legacy value', () async {
      await const PersonalProfileData().write(
        PersonalProfile.defaultProfile.copyWith(firstName: 'Legacy'),
      );
      final data = build(FakeProfileDao());
      await data.read();

      await data.write(
        PersonalProfile.defaultProfile.copyWith(firstName: 'Newer'),
      );

      expect((await data.read()).firstName, 'Newer');
    });
  });
}
