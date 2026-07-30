/// Integration testing — the legacy SharedPreferences data sources.
///
/// These classes predate the SQLite migration and are still on the read path:
/// on first launch after an update they are what the SQLite layer migrates
/// *from*. They run against the real `shared_preferences` mock, so these are
/// integration rather than unit tests.
///
/// The recurring concern is that every one of them must survive a corrupted
/// payload by falling back, never by throwing — the stored string is written
/// by an older version of the app and cannot be trusted.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:travelmate/shared/data/chat_history_data.dart';
import 'package:travelmate/shared/data/personal_profile_data.dart';
import 'package:travelmate/shared/data/privacy_settings_data.dart';
import 'package:travelmate/shared/data/saved_bookmarks_data.dart';
import 'package:travelmate/shared/models/personal_profile.dart';
import 'package:travelmate/shared/models/privacy_settings.dart';

import '../helpers/fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ChatHistoryData', () {
    test('returns an empty map when nothing is stored', () async {
      expect(await const ChatHistoryData().readAll(), isEmpty);
    });

    test('writes and reads conversations', () async {
      const data = ChatHistoryData();

      await data.writeAll({
        'mate_1': [buildMessage('1', text: 'hi')],
      });

      final restored = await data.readAll();
      expect(restored.keys, contains('mate_1'));
      expect(restored['mate_1']!.single.text, 'hi');
    });

    test('writes and reads several conversations at once', () async {
      const data = ChatHistoryData();

      await data.writeAll({
        'mate_1': [buildMessage('1', text: 'a'), buildMessage('2', text: 'b')],
        'mate_2': [buildMessage('3', text: 'c')],
      });

      final restored = await data.readAll();
      expect(restored['mate_1']!.map((message) => message.text), ['a', 'b']);
      expect(restored['mate_2']!.single.text, 'c');
    });

    test('returns empty on a corrupted payload', () async {
      SharedPreferences.setMockInitialValues({'chat_history_v1': 'not-json'});

      expect(await const ChatHistoryData().readAll(), isEmpty);
    });
  });

  group('PersonalProfileData', () {
    test('returns the default when nothing is stored', () async {
      final profile = await const PersonalProfileData().read();

      expect(profile.firstName, PersonalProfile.defaultProfile.firstName);
    });

    test('writes and reads a profile', () async {
      const data = PersonalProfileData();

      await data.write(
        PersonalProfile.defaultProfile.copyWith(firstName: 'Nina'),
      );

      expect((await data.read()).firstName, 'Nina');
    });

    test('returns the default on a corrupted payload', () async {
      SharedPreferences.setMockInitialValues({
        'personal_profile_v1': '[not-a-map]',
      });

      final profile = await const PersonalProfileData().read();
      expect(profile.firstName, PersonalProfile.defaultProfile.firstName);
    });
  });

  group('PrivacySettingsData', () {
    test('returns the defaults when nothing is stored', () async {
      expect(
        (await const PrivacySettingsData().read()).privateProfile,
        isFalse,
      );
    });

    test('writes and reads settings', () async {
      const data = PrivacySettingsData();

      await data.write(
        const PrivacySettings(
          privateProfile: true,
          onlyPeopleInRadius: false,
          checkMessages: false,
          offlineMode: true,
        ),
      );

      final restored = await data.read();
      expect(restored.privateProfile, isTrue);
      expect(restored.offlineMode, isTrue);
      expect(restored.checkMessages, isFalse);
    });

    test('returns the defaults on a corrupted payload', () async {
      SharedPreferences.setMockInitialValues({'privacy_settings_v1': 'oops'});

      expect(
        (await const PrivacySettingsData().read()).privateProfile,
        isFalse,
      );
    });
  });

  group('SavedBookmarksData', () {
    test('returns empty when nothing is stored', () async {
      expect(await const SavedBookmarksData().readAll(), isEmpty);
    });

    test('writes and reads bookmarks, preserving order', () async {
      const data = SavedBookmarksData();

      await data.writeAll([
        buildBookmark(sourceId: 'trip_1'),
        buildBookmark(sourceId: 'trip_2'),
      ]);

      final restored = await data.readAll();
      expect(restored.map((entry) => entry.sourceId), ['trip_1', 'trip_2']);
    });

    test('returns empty on a corrupted payload', () async {
      SharedPreferences.setMockInitialValues({'saved_bookmarks_v1': '{bad'});

      expect(await const SavedBookmarksData().readAll(), isEmpty);
    });
  });
}
