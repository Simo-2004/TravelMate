import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:travelmate/core/database/profile_dao.dart';
import 'package:travelmate/core/security/aes_cipher.dart';
import 'package:travelmate/core/security/profile_key_provider.dart';
import 'package:travelmate/core/security/secure_key_store.dart';
import 'package:travelmate/features/profile/image/profile_image_storage.dart';
import 'package:travelmate/features/profile/personal_profile_screen.dart';
import 'package:travelmate/shared/data/personal_profile_data.dart';
import 'package:travelmate/shared/data/profile_repository.dart';
import 'package:travelmate/shared/data/sqlite_profile_data.dart';
import 'package:travelmate/shared/models/personal_profile.dart';
import 'package:travelmate/shared/state/personal_profile_store.dart';
import 'package:travelmate/shared/widgets/profile_photo.dart';

import 'helpers/test_harness.dart';

/// In-memory [ProfileDao] so the repository logic runs without a native SQLite.
class _FakeProfileDao implements ProfileDao {
  Map<String, Object?>? row;

  @override
  Future<Map<String, Object?>?> readProfileRow() async => row;

  @override
  Future<void> upsertProfileRow(Map<String, Object?> newRow) async {
    row = Map<String, Object?>.from(newRow);
  }
}

/// In-memory [SecureKeyStore] that counts writes, for the key-provider tests.
class _FakeSecureKeyStore implements SecureKeyStore {
  final Map<String, String> values = {};
  int writes = 0;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
    writes++;
  }
}

AesCipher _testCipher() => AesCipher(enc.Key.fromLength(32));

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  group('AesCipher', () {
    test('round-trips text through encryption', () {
      final cipher = _testCipher();
      const plain = 'Alessia Rossi — beach lover';

      final payload = cipher.encryptString(plain);

      expect(payload, isNot(plain));
      expect(cipher.decryptString(payload), plain);
    });

    test('produces a different payload each call (random nonce)', () {
      final cipher = _testCipher();

      final a = cipher.encryptString('same');
      final b = cipher.encryptString('same');

      expect(a, isNot(b));
      expect(cipher.decryptString(a), 'same');
      expect(cipher.decryptString(b), 'same');
    });

    test('throws when the payload was tampered with', () {
      final cipher = _testCipher();
      final bytes = base64Decode(cipher.encryptString('secret'));
      bytes[bytes.length - 1] ^= 0xFF; // corrupt the GCM tag

      expect(
        () => cipher.decryptString(base64Encode(bytes)),
        throwsA(anything),
      );
    });

    test('throws when decrypting with a different key', () {
      final payload = _testCipher().encryptString('secret');
      final other = AesCipher(enc.Key.fromSecureRandom(32));

      expect(() => other.decryptString(payload), throwsA(anything));
    });

    test('rejects a payload shorter than the nonce', () {
      final cipher = _testCipher();

      expect(
        () => cipher.decryptString(base64Encode([1, 2, 3])),
        throwsFormatException,
      );
    });
  });

  group('ProfileKeyProvider', () {
    test('generates and stores a key on first use', () async {
      final store = _FakeSecureKeyStore();
      final provider = ProfileKeyProvider(store);

      final key = await provider.getOrCreateKey();

      expect(key.bytes.length, 32);
      expect(store.writes, 1);
      expect(store.values.values.single, key.base64);
    });

    test('reuses the stored key and memoizes it', () async {
      final store = _FakeSecureKeyStore();

      final first = await ProfileKeyProvider(store).getOrCreateKey();

      final reloaded = ProfileKeyProvider(store);
      final second = await reloaded.getOrCreateKey();
      final third = await reloaded.getOrCreateKey();

      expect(second.base64, first.base64);
      expect(third.base64, first.base64);
      expect(store.writes, 1); // no extra writes on reuse
    });
  });

  group('ProfileRepository', () {
    ProfileRepository build(_FakeProfileDao dao) {
      final cipher = _testCipher();
      return ProfileRepository(dao: dao, cipher: () async => cipher);
    }

    test('returns null when nothing is stored', () async {
      expect(await build(_FakeProfileDao()).readProfile(), isNull);
    });

    test('encrypts fields on write and restores them on read', () async {
      final dao = _FakeProfileDao();
      final repository = build(dao);
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
  });

  group('SqliteProfileData', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    SqliteProfileData build(_FakeProfileDao dao) {
      final cipher = _testCipher();
      return SqliteProfileData(
        repository: ProfileRepository(dao: dao, cipher: () async => cipher),
      );
    }

    test('falls back to the default profile when nothing exists', () async {
      final profile = await build(_FakeProfileDao()).read();
      expect(profile.firstName, PersonalProfile.defaultProfile.firstName);
    });

    test('migrates a legacy SharedPreferences profile into the db', () async {
      await const PersonalProfileData().write(
        PersonalProfile.defaultProfile.copyWith(firstName: 'Legacy'),
      );

      final dao = _FakeProfileDao();
      final data = build(dao);

      final migrated = await data.read();
      expect(migrated.firstName, 'Legacy');
      expect(dao.row, isNotNull); // written through to the encrypted db

      // A subsequent read now comes from the db, not the legacy store.
      expect((await data.read()).firstName, 'Legacy');
    });

    test('persists writes through the repository', () async {
      final dao = _FakeProfileDao();
      final data = build(dao);

      await data.write(
        PersonalProfile.defaultProfile.copyWith(firstName: 'Saved'),
      );

      expect((await data.read()).firstName, 'Saved');
    });
  });

  group('ProfileImageStorage', () {
    test('copies the source into a profile_images subfolder', () async {
      final storage = const ProfileImageStorage();
      final documentsDir = await Directory.systemTemp.createTemp('docs');
      final sourceDir = await Directory.systemTemp.createTemp('src');
      final source = File('${sourceDir.path}/pick.png');
      await source.writeAsBytes([1, 2, 3, 4]);

      final savedPath = await storage.saveProfileImage(
        source: source,
        documentsDir: documentsDir,
        now: DateTime.fromMillisecondsSinceEpoch(42),
      );

      final saved = File(savedPath);
      expect(savedPath, contains(ProfileImageStorage.folderName));
      expect(savedPath, endsWith('.png'));
      expect(await saved.exists(), isTrue);
      expect(await saved.readAsBytes(), [1, 2, 3, 4]);

      await documentsDir.delete(recursive: true);
      await sourceDir.delete(recursive: true);
    });
  });

  group('ProfilePhoto', () {
    testWidgets('shows a placeholder icon for an empty source', (tester) async {
      await tester.pumpWidget(
        wrapScaffold(const ProfilePhoto(source: '', size: 60)),
      );

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('renders a bundled SVG asset', (tester) async {
      await tester.pumpWidget(
        wrapScaffold(
          const ProfilePhoto(source: 'assets/icons/user_icon.svg', size: 60),
        ),
      );
      await tester.pump();

      expect(find.byType(ProfilePhoto), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsNothing);
    });

    testWidgets('uses Image.file for an absolute file path', (tester) async {
      await tester.pumpWidget(
        wrapScaffold(
          const ProfilePhoto(source: '/tmp/does_not_exist.png', size: 60),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('PersonalProfileScreen photo upload', () {
    setUp(() {
      PersonalProfileStore.instance.value = PersonalProfile.defaultProfile;
      PersonalProfileStore.instance.debugSetDataSource(InMemoryProfileData());

      // Render at a phone-sized surface so the edit controls are on-screen.
      final view = binding.platformDispatcher.implicitView!;
      view.devicePixelRatio = 1.0;
      view.physicalSize = const Size(400, 900);
      addTearDown(() {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
      });
    });

    testWidgets('stores the picked photo path on save', (tester) async {
      const pickedPath = '/tmp/uploaded_profile.png';

      await tester.pumpWidget(
        wrapApp(const PersonalProfileScreen(photoPicker: _fixedPicker)),
      );
      await tester.pump();

      await tester.tap(find.text('Edit profile'));
      await tester.pump();

      await tester.ensureVisible(find.text('Upload photo'));
      await tester.tap(find.text('Upload photo'));
      await tester.pump();

      await tester.ensureVisible(find.text('Save profile changes'));
      await tester.tap(find.text('Save profile changes'));
      await tester.pump();

      expect(PersonalProfileStore.instance.value.photoAsset, pickedPath);
    });

    testWidgets('shows an error when picking fails', (tester) async {
      await tester.pumpWidget(
        wrapApp(const PersonalProfileScreen(photoPicker: _throwingPicker)),
      );
      await tester.pump();

      await tester.tap(find.text('Edit profile'));
      await tester.pump();

      await tester.ensureVisible(find.text('Upload photo'));
      await tester.tap(find.text('Upload photo'));
      await tester.pump();

      expect(find.text('Could not load the selected photo.'), findsOneWidget);
    });
  });
}

Future<String?> _fixedPicker() async => '/tmp/uploaded_profile.png';

Future<String?> _throwingPicker() async => throw Exception('picker failed');
