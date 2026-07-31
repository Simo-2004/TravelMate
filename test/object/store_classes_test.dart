/// Object class testing — the singleton stores.
///
/// Each store is a small state machine: it starts in a known state, exposes a
/// handful of mutating operations, and notifies listeners when the state moves.
/// The tests below drive one store at a time over its full API, against
/// in-memory persistence so no plugin is involved.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:travelmate/shared/data/privacy_settings_data.dart';
import 'package:travelmate/shared/data/saved_bookmarks_data.dart';
import 'package:travelmate/shared/data/trip_repository.dart';
import 'package:travelmate/shared/models/personal_profile.dart';
import 'package:travelmate/shared/models/privacy_settings.dart';
import 'package:travelmate/shared/models/saved_trip_preview.dart';
import 'package:travelmate/shared/models/search_research_mode.dart';
import 'package:travelmate/shared/state/auth_service.dart';
import 'package:travelmate/shared/state/personal_profile_store.dart';
import 'package:travelmate/shared/state/privacy_settings_store.dart';
import 'package:travelmate/shared/state/saved_trip_preview_store.dart';
import 'package:travelmate/shared/state/search_research_mode_store.dart';
import 'package:travelmate/shared/state/trip_store.dart';

import '../helpers/test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PersonalProfileStore', () {
    setUp(() {
      PersonalProfileStore.instance
        ..value = PersonalProfile.defaultProfile
        ..debugSetDataSource(InMemoryProfileData());
    });

    test('initialize loads the persisted profile', () async {
      PersonalProfileStore.instance.debugSetDataSource(
        InMemoryProfileData(
          PersonalProfile.defaultProfile.copyWith(firstName: 'Loaded'),
        ),
      );

      await PersonalProfileStore.instance.initialize();

      expect(PersonalProfileStore.instance.value.firstName, 'Loaded');
    });

    test('initialize is idempotent — a second call does not reload', () async {
      final source = InMemoryProfileData(
        PersonalProfile.defaultProfile.copyWith(firstName: 'First'),
      );
      PersonalProfileStore.instance.debugSetDataSource(source);

      await PersonalProfileStore.instance.initialize();
      // Change the profile in memory, then initialize again: the second call
      // must be a no-op rather than overwriting the live value from storage.
      PersonalProfileStore.instance.updateName(firstName: 'Edited');
      await PersonalProfileStore.instance.initialize();

      expect(PersonalProfileStore.instance.value.firstName, 'Edited');
    });

    test('update helpers change exactly one field each', () {
      final store = PersonalProfileStore.instance;

      store.updateDescription('New description');
      expect(store.value.description, 'New description');
      expect(store.value.firstName, PersonalProfile.defaultProfile.firstName);

      store.updatePhotoAsset('new.svg');
      expect(store.value.photoAsset, 'new.svg');
      expect(store.value.description, 'New description');

      store.updateName(firstName: 'Ann', lastName: 'Lee');
      expect(store.value.fullName, 'Ann Lee');
      expect(store.value.photoAsset, 'new.svg');
    });

    test('updateName accepts a single side of the name', () {
      final store = PersonalProfileStore.instance;

      store.updateName(firstName: 'Solo');

      expect(store.value.firstName, 'Solo');
      expect(store.value.lastName, PersonalProfile.defaultProfile.lastName);
    });

    test('every update notifies listeners and persists', () async {
      final store = PersonalProfileStore.instance;
      final source = InMemoryProfileData();
      store.debugSetDataSource(source);

      var notifications = 0;
      void listener() => notifications++;
      store.addListener(listener);
      addTearDown(() => store.removeListener(listener));

      store.updateDescription('Persisted');
      await Future<void>.delayed(Duration.zero);

      expect(notifications, 1);
      expect((await source.read()).description, 'Persisted');
    });
  });

  group('PrivacySettingsStore', () {
    test('initialize loads persisted settings and is idempotent', () async {
      await const PrivacySettingsData().write(
        PrivacySettings.defaults.copyWithKey(
          PrivacySettingKey.privateProfile,
          true,
        ),
      );

      await PrivacySettingsStore.instance.initialize();
      await PrivacySettingsStore.instance.initialize();

      expect(PrivacySettingsStore.instance.value.privateProfile, isTrue);
    });

    test('updateSettings replaces the whole value', () {
      final store = PrivacySettingsStore.instance;

      store.updateSettings(PrivacySettings.defaults);

      expect(store.value.offlineMode, isFalse);
      expect(store.value.privateProfile, isFalse);
    });

    test('updateSetting flips a single key both ways', () {
      final store = PrivacySettingsStore.instance;
      store.updateSettings(PrivacySettings.defaults);

      store.updateSetting(PrivacySettingKey.offlineMode, true);
      expect(store.value.offlineMode, isTrue);

      store.updateSetting(PrivacySettingKey.offlineMode, false);
      expect(store.value.offlineMode, isFalse);
    });

    test('every key is independently settable through the store', () {
      final store = PrivacySettingsStore.instance;
      store.updateSettings(PrivacySettings.defaults);

      for (final key in PrivacySettingKey.values) {
        store.updateSetting(key, true);
        expect(store.value.valueFor(key), isTrue, reason: 'setting $key');
        store.updateSetting(key, false);
        expect(store.value.valueFor(key), isFalse, reason: 'clearing $key');
      }
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

    test('toggle notifies listeners each time', () {
      final store = SearchResearchModeStore.instance;
      store.value = SearchResearchMode.trips;

      var notifications = 0;
      void listener() => notifications++;
      store.addListener(listener);
      addTearDown(() => store.removeListener(listener));

      store
        ..toggle()
        ..toggle();

      expect(notifications, 2);
    });
  });

  group('SavedTripPreviewStore', () {
    setUp(() {
      SavedTripPreviewStore.instance.value = const [];
    });

    test('initialize loads persisted bookmarks and is idempotent', () async {
      await const SavedBookmarksData().writeAll([
        buildBookmark(sourceId: 'trip_7'),
      ]);

      await SavedTripPreviewStore.instance.initialize();
      await SavedTripPreviewStore.instance.initialize();

      expect(SavedTripPreviewStore.instance.value.single.sourceId, 'trip_7');
    });

    test('stages, detects, toggles and removes bookmarks', () {
      final store = SavedTripPreviewStore.instance;
      final bookmark = buildBookmark(name: 'Trip 2', sourceId: 'trip_2');

      expect(store.isSaved(bookmark), isFalse);

      expect(store.toggleBookmark(bookmark), isTrue);
      expect(store.isSaved(bookmark), isTrue);
      expect(store.value, hasLength(1));

      expect(store.toggleBookmark(bookmark), isFalse);
      expect(store.isSaved(bookmark), isFalse);
      expect(store.value, isEmpty);
    });

    test('stageTrip inserts most recent first', () {
      final store = SavedTripPreviewStore.instance;

      store
        ..stageTrip(buildBookmark(name: 'A', sourceId: 'trip_1'))
        ..stageTrip(buildBookmark(name: 'B', sourceId: 'trip_2'));

      expect(store.value.first.sourceId, 'trip_2');
    });

    test('staging the same bookmark twice does not duplicate it', () {
      final store = SavedTripPreviewStore.instance;
      final bookmark = buildBookmark(sourceId: 'trip_1');

      store
        ..stageBookmark(bookmark)
        ..stageBookmark(bookmark);

      expect(store.value, hasLength(1));
    });

    test('matches mate bookmarks by name when sourceId is empty', () {
      final store = SavedTripPreviewStore.instance;
      final mate = buildBookmark(
        name: 'Alessia',
        sourceId: '',
        type: SavedBookmarkType.mate,
      );

      store.stageBookmark(mate);

      expect(store.isSaved(mate), isTrue);
    });

    test('different bookmark types are never considered equal', () {
      final store = SavedTripPreviewStore.instance;
      store.stageBookmark(buildBookmark(name: 'X', sourceId: 'trip_1'));

      final asMate = buildBookmark(
        name: 'X',
        sourceId: 'trip_1',
        type: SavedBookmarkType.mate,
      );

      expect(store.isSaved(asMate), isFalse);
    });

    test('matches a trip bookmark by destination title without a sourceId', () {
      final store = SavedTripPreviewStore.instance;
      store.stageBookmark(
        buildBookmark(
          name: 'Trip A',
          sourceId: '',
          destinationTitle: 'Same Dest',
        ),
      );

      expect(
        store.isSaved(
          buildBookmark(
            name: 'Different name',
            sourceId: '',
            destinationTitle: 'Same Dest',
          ),
        ),
        isTrue,
      );
    });

    test('removeBookmark drops the matching entry and leaves the rest', () {
      final store = SavedTripPreviewStore.instance;
      final target = buildBookmark(name: 'Nine', sourceId: 'trip_9');

      store
        ..stageBookmark(buildBookmark(name: 'One', sourceId: 'trip_1'))
        ..stageBookmark(target)
        ..removeBookmark(target);

      expect(store.value.map((entry) => entry.sourceId), ['trip_1']);
    });

    test('removeBookmark is a no-op for an entry that was never saved', () {
      final store = SavedTripPreviewStore.instance;
      store.stageBookmark(
        buildBookmark(sourceId: 'trip_1', destinationTitle: 'Bali'),
      );

      store.removeBookmark(
        buildBookmark(sourceId: 'trip_99', destinationTitle: 'Alps'),
      );

      expect(store.value, hasLength(1));
    });

    test('an id-less lookup matches a stored trip by destination title', () {
      // The screen can ask "is this saved?" with a preview it rebuilt from a
      // catalog entry that carries no sourceId. The stored record has one, so
      // the titles are what has to line up.
      final store = SavedTripPreviewStore.instance;
      store.stageBookmark(
        buildBookmark(sourceId: 'trip_1', destinationTitle: 'Bali'),
      );

      expect(
        store.isSaved(
          buildBookmark(
            name: 'a different name',
            sourceId: '',
            destinationTitle: 'Bali',
          ),
        ),
        isTrue,
      );
      expect(
        store.isSaved(
          buildBookmark(sourceId: '', destinationTitle: 'Somewhere else'),
        ),
        isFalse,
      );
    });

    test('an id-less mate lookup never matches a stored trip', () {
      final store = SavedTripPreviewStore.instance;
      store.stageBookmark(
        buildBookmark(sourceId: 'trip_1', destinationTitle: 'Bali'),
      );

      expect(
        store.isSaved(
          buildBookmark(
            sourceId: '',
            destinationTitle: 'Bali',
            type: SavedBookmarkType.mate,
          ),
        ),
        isFalse,
      );
    });

    test('a legacy record saved under a label id still matches by title', () {
      // Older builds used the trip label as the sourceId. Such a record must
      // still be recognised as the same bookmark as the canonical one.
      final store = SavedTripPreviewStore.instance;
      store.stageBookmark(
        buildBookmark(sourceId: 'beach-escape', destinationTitle: 'Bali'),
      );

      expect(
        store.isSaved(
          buildBookmark(sourceId: 'trip_1', destinationTitle: 'Bali'),
        ),
        isTrue,
      );
    });
  });

  group('TripStore', () {
    TripStore buildStore() {
      return TripStore.withRepository(
        TripRepository(
          dao: FakeTripDao(),
          seedTrips: [
            buildTrip(id: 'trip_1', label: 'A'),
            buildTrip(id: 'trip_2', label: 'B'),
          ],
          seedRecents: [buildTrip(id: 'trip_1', label: 'Recent A')],
        ),
      );
    }

    test('starts empty before initialize', () {
      final store = buildStore();

      expect(store.trips, isEmpty);
      expect(store.recents, isEmpty);
      expect(store.findTripById('trip_1'), isNull);
    });

    test('initialize seeds, loads and exposes lookups', () async {
      final store = buildStore();

      await store.initialize();
      await store.initialize(); // idempotent

      expect(store.trips.map((trip) => trip.label), ['A', 'B']);
      expect(store.recents.single.label, 'Recent A');
      expect(store.findTripById('trip_2')!.label, 'B');
    });

    test('findTripById normalises case and whitespace', () async {
      final store = buildStore();
      await store.initialize();

      expect(store.findTripById('  TRIP_1 ')!.tripId, 'trip_1');
    });

    test('findTripById returns null for blank and unknown ids', () async {
      final store = buildStore();
      await store.initialize();

      expect(store.findTripById(''), isNull);
      expect(store.findTripById('   '), isNull);
      expect(store.findTripById('missing'), isNull);
    });

    test('debugSetData replaces the in-memory catalog and its index', () {
      final store = TripStore.withRepository(
        TripRepository(dao: FakeTripDao()),
      );

      store.debugSetData(
        trips: [buildTrip(id: 'trip_9', label: 'Nine')],
        recents: const [],
      );

      expect(store.findTripById('trip_9')!.label, 'Nine');
      expect(store.findTripById('trip_1'), isNull);
      expect(store.recents, isEmpty);
    });
  });

  group('AuthService', () {
    test('initialize seeds the default account and authenticates it', () async {
      AuthService.instance.debugSetRepository(
        testAccountRepository(FakeAccountDao()),
      );

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

    test(
      'createAccount replaces the credentials used by authenticate',
      () async {
        AuthService.instance.debugSetRepository(
          testAccountRepository(FakeAccountDao()),
        );
        await AuthService.instance.initialize();

        await AuthService.instance.createAccount('newbie', 'password1');

        expect(
          await AuthService.instance.authenticate('newbie', 'password1'),
          isTrue,
        );
        expect(
          await AuthService.instance.authenticate(
            AuthService.defaultUsername,
            AuthService.defaultPassword,
          ),
          isFalse,
        );
      },
    );
  });
}
