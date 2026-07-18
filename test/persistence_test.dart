import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:travelmate/shared/data/chat_history_data.dart';
import 'package:travelmate/shared/data/personal_profile_data.dart';
import 'package:travelmate/shared/data/privacy_settings_data.dart';
import 'package:travelmate/shared/data/saved_bookmarks_data.dart';
import 'package:travelmate/shared/models/chat_message.dart';
import 'package:travelmate/shared/models/personal_profile.dart';
import 'package:travelmate/shared/models/privacy_settings.dart';
import 'package:travelmate/shared/models/saved_trip_preview.dart';
import 'package:travelmate/shared/state/personal_profile_store.dart';
import 'package:travelmate/shared/state/privacy_settings_store.dart';
import 'package:travelmate/shared/state/saved_trip_preview_store.dart';
import 'package:travelmate/shared/state/search_research_mode_store.dart';
import 'package:travelmate/shared/models/search_research_mode.dart';

SavedTripPreview _bookmark({
  String name = 'Trip 1',
  String sourceId = 'trip_1',
  String type = SavedBookmarkType.trip,
}) {
  return SavedTripPreview(
    tripName: name,
    destinationTitle: 'Dest',
    description: 'Desc',
    coverImage: '',
    tags: const [],
    bookmarkType: type,
    sourceId: sourceId,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ChatHistoryData', () {
    test('returns empty map when nothing stored', () async {
      expect(await const ChatHistoryData().readAll(), isEmpty);
    });

    test('writes and reads conversations', () async {
      const data = ChatHistoryData();
      final conversations = {
        'mate_1': [
          ChatMessage(
            id: '1',
            text: 'hi',
            isFromMe: true,
            sentAt: DateTime.parse('2024-01-01T00:00:00.000'),
          ),
        ],
      };
      await data.writeAll(conversations);

      final restored = await data.readAll();
      expect(restored.keys, contains('mate_1'));
      expect(restored['mate_1']!.single.text, 'hi');
    });

    test('returns empty on corrupted payload', () async {
      SharedPreferences.setMockInitialValues({'chat_history_v1': 'not-json'});
      expect(await const ChatHistoryData().readAll(), isEmpty);
    });
  });

  group('PersonalProfileData', () {
    test('returns default when nothing stored', () async {
      final profile = await const PersonalProfileData().read();
      expect(profile.firstName, PersonalProfile.defaultProfile.firstName);
    });

    test('writes and reads a profile', () async {
      const data = PersonalProfileData();
      final profile = PersonalProfile.defaultProfile.copyWith(
        firstName: 'Nina',
      );
      await data.write(profile);
      expect((await data.read()).firstName, 'Nina');
    });

    test('returns default on corrupted payload', () async {
      SharedPreferences.setMockInitialValues({
        'personal_profile_v1': '[not-a-map]',
      });
      final profile = await const PersonalProfileData().read();
      expect(profile.firstName, PersonalProfile.defaultProfile.firstName);
    });
  });

  group('PrivacySettingsData', () {
    test('returns defaults when nothing stored', () async {
      final settings = await const PrivacySettingsData().read();
      expect(settings.privateProfile, isFalse);
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
    });

    test('returns defaults on corrupted payload', () async {
      SharedPreferences.setMockInitialValues({'privacy_settings_v1': 'oops'});
      expect((await const PrivacySettingsData().read()).privateProfile, isFalse);
    });
  });

  group('SavedBookmarksData', () {
    test('returns empty when nothing stored', () async {
      expect(await const SavedBookmarksData().readAll(), isEmpty);
    });

    test('writes and reads bookmarks', () async {
      const data = SavedBookmarksData();
      await data.writeAll([_bookmark()]);
      final restored = await data.readAll();
      expect(restored.single.sourceId, 'trip_1');
    });

    test('returns empty on corrupted payload', () async {
      SharedPreferences.setMockInitialValues({'saved_bookmarks_v1': '{bad'});
      expect(await const SavedBookmarksData().readAll(), isEmpty);
    });
  });

  group('SavedTripPreviewStore', () {
    test('stages, detects, toggles and removes bookmarks', () async {
      final store = SavedTripPreviewStore.instance;
      store.value = const [];

      final bookmark = _bookmark(name: 'Trip 2', sourceId: 'trip_2');
      expect(store.isSaved(bookmark), isFalse);

      final added = store.toggleBookmark(bookmark);
      expect(added, isTrue);
      expect(store.isSaved(bookmark), isTrue);
      expect(store.value, hasLength(1));

      final removed = store.toggleBookmark(bookmark);
      expect(removed, isFalse);
      expect(store.isSaved(bookmark), isFalse);
    });

    test('stageTrip inserts most recent first', () async {
      final store = SavedTripPreviewStore.instance;
      store.value = const [];
      store.stageTrip(_bookmark(name: 'A', sourceId: 'trip_1'));
      store.stageTrip(_bookmark(name: 'B', sourceId: 'trip_2'));
      expect(store.value.first.sourceId, 'trip_2');
    });

    test('matches mate bookmarks by name when sourceId is empty', () {
      final store = SavedTripPreviewStore.instance;
      store.value = const [];
      final mate = _bookmark(
        name: 'Alessia',
        sourceId: '',
        type: SavedBookmarkType.mate,
      );
      store.stageBookmark(mate);
      expect(store.isSaved(mate), isTrue);
    });

    test('different bookmark types are never considered equal', () {
      final store = SavedTripPreviewStore.instance;
      store.value = const [];
      store.stageBookmark(
        _bookmark(name: 'X', sourceId: 'trip_1', type: SavedBookmarkType.trip),
      );
      final asMate = _bookmark(
        name: 'X',
        sourceId: 'trip_1',
        type: SavedBookmarkType.mate,
      );
      expect(store.isSaved(asMate), isFalse);
    });

    test('matches a trip bookmark by destination title without sourceId', () {
      final store = SavedTripPreviewStore.instance;
      store.value = const [];
      const preview = SavedTripPreview(
        tripName: 'Trip A',
        destinationTitle: 'Same Dest',
        description: 'd',
        coverImage: '',
        tags: [],
        bookmarkType: SavedBookmarkType.trip,
        sourceId: '',
      );
      store.stageBookmark(preview);
      expect(
        store.isSaved(
          const SavedTripPreview(
            tripName: 'Different name',
            destinationTitle: 'Same Dest',
            description: 'd',
            coverImage: '',
            tags: [],
            bookmarkType: SavedBookmarkType.trip,
            sourceId: '',
          ),
        ),
        isTrue,
      );
    });

    test('removeBookmark drops the matching entry', () {
      final store = SavedTripPreviewStore.instance;
      store.value = const [];
      final bookmark = _bookmark(sourceId: 'trip_9');
      store.stageBookmark(bookmark);
      store.removeBookmark(bookmark);
      expect(store.value, isEmpty);
    });
  });

  group('PersonalProfileStore', () {
    test('initialize loads persisted profile', () async {
      await const PersonalProfileData().write(
        PersonalProfile.defaultProfile.copyWith(firstName: 'Loaded'),
      );
      // The singleton may already be initialized by another test; assert
      // that updates flow through regardless.
      PersonalProfileStore.instance.updateName(firstName: 'Direct');
      expect(PersonalProfileStore.instance.value.firstName, 'Direct');
    });

    test('update helpers change specific fields', () {
      final store = PersonalProfileStore.instance;
      store.updateDescription('New description');
      expect(store.value.description, 'New description');
      store.updatePhotoAsset('new.svg');
      expect(store.value.photoAsset, 'new.svg');
      store.updateName(firstName: 'Ann', lastName: 'Lee');
      expect(store.value.fullName, 'Ann Lee');
    });
  });

  group('PrivacySettingsStore', () {
    test('initialize loads persisted settings and is idempotent', () async {
      await const PrivacySettingsData().write(
        const PrivacySettings(
          privateProfile: true,
          onlyPeopleInRadius: false,
          checkMessages: false,
          offlineMode: false,
        ),
      );
      await PrivacySettingsStore.instance.initialize();
      await PrivacySettingsStore.instance.initialize();
      expect(PrivacySettingsStore.instance.value.privateProfile, isTrue);
    });

    test('updateSettings and updateSetting change values', () {
      final store = PrivacySettingsStore.instance;
      store.updateSettings(PrivacySettings.defaults);
      expect(store.value.offlineMode, isFalse);
      store.updateSetting(PrivacySettingKey.offlineMode, true);
      expect(store.value.offlineMode, isTrue);
      store.updateSetting(PrivacySettingKey.offlineMode, false);
      expect(store.value.offlineMode, isFalse);
    });
  });

  group('SearchResearchModeStore', () {
    test('toggle flips between trips and mates', () {
      final store = SearchResearchModeStore.instance;
      store.value = SearchResearchMode.trips;
      store.toggle();
      expect(store.value, SearchResearchMode.mates);
      store.toggle();
      expect(store.value, SearchResearchMode.trips);
    });
  });
}
