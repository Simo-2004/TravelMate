/// Object class testing — the domain models.
///
/// Where a unit test exercises one function, an object class test exercises
/// *one class*: every operation it exposes, over every state it can hold. For
/// these models that means the constructor defaults, the derived getters,
/// `copyWith`, and the full JSON round trip — including how each class behaves
/// when handed the malformed data that a real storage layer eventually
/// produces.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/shared/models/chat_message.dart';
import 'package:travelmate/shared/models/personal_profile.dart';
import 'package:travelmate/shared/models/privacy_settings.dart';
import 'package:travelmate/shared/models/saved_trip_preview.dart';
import 'package:travelmate/shared/models/search_research_mode.dart';
import 'package:travelmate/shared/models/trip_tag.dart';

import '../helpers/fixtures.dart';

void main() {
  group('PersonalProfile', () {
    test('fullName joins first and last', () {
      const profile = PersonalProfile(
        firstName: 'Anna',
        lastName: 'Bianchi',
        description: 'd',
        photoAsset: 'a.svg',
      );
      expect(profile.fullName, 'Anna Bianchi');
    });

    test('fullName falls back when both names are empty', () {
      const profile = PersonalProfile(
        firstName: '',
        lastName: '',
        description: 'd',
        photoAsset: 'a.svg',
      );
      expect(profile.fullName, 'Traveler profile');
    });

    test('fullName trims when only one name is present', () {
      const profile = PersonalProfile(
        firstName: 'Anna',
        lastName: '',
        description: 'd',
        photoAsset: 'a.svg',
      );
      expect(profile.fullName, 'Anna');
    });

    test('tag lists default to empty', () {
      const profile = PersonalProfile(
        firstName: 'A',
        lastName: 'B',
        description: 'd',
        photoAsset: 'a.svg',
      );
      expect(profile.interestTags, isEmpty);
      expect(profile.tripTags, isEmpty);
    });

    test('copyWith overrides only the given fields', () {
      final updated = PersonalProfile.defaultProfile.copyWith(firstName: 'Zoe');

      expect(updated.firstName, 'Zoe');
      expect(updated.lastName, PersonalProfile.defaultProfile.lastName);
      expect(updated.description, PersonalProfile.defaultProfile.description);
    });

    test('copyWith with no arguments reproduces the same values', () {
      final copy = PersonalProfile.defaultProfile.copyWith();

      expect(copy.firstName, PersonalProfile.defaultProfile.firstName);
      expect(copy.interestTags, PersonalProfile.defaultProfile.interestTags);
    });

    test('copyWith detaches the tag lists from the caller', () {
      final tags = ['Beach'];
      final profile = PersonalProfile.defaultProfile.copyWith(
        interestTags: tags,
      );

      tags.add('Mutated after the fact');

      expect(profile.interestTags, ['Beach']);
    });

    test('round-trips through JSON', () {
      final restored = PersonalProfile.fromJson(
        PersonalProfile.defaultProfile.toJson(),
      );

      expect(restored.firstName, PersonalProfile.defaultProfile.firstName);
      expect(restored.lastName, PersonalProfile.defaultProfile.lastName);
      expect(restored.photoAsset, PersonalProfile.defaultProfile.photoAsset);
      expect(restored.interestTags, isNotEmpty);
    });

    test('fromJson falls back for blank strings and bad lists', () {
      final restored = PersonalProfile.fromJson({
        'firstName': '   ',
        'interestTags': 'not-a-list',
      });

      expect(restored.firstName, PersonalProfile.defaultProfile.firstName);
      expect(
        restored.interestTags,
        PersonalProfile.defaultProfile.interestTags,
      );
    });

    test('fromJson falls back for wrongly typed scalars', () {
      final restored = PersonalProfile.fromJson({'firstName': 42});

      expect(restored.firstName, PersonalProfile.defaultProfile.firstName);
    });

    test('fromJson dedupes, trims and drops blank list entries', () {
      final restored = PersonalProfile.fromJson({
        'tripTags': ['  a ', 'a', 'b', '', 7],
      });

      expect(restored.tripTags, ['a', 'b']);
    });

    test('fromJson accepts an explicitly empty list as empty', () {
      final restored = PersonalProfile.fromJson({'tripTags': <String>[]});

      expect(restored.tripTags, isEmpty);
    });

    test('fromJson on an empty map yields the default profile', () {
      final restored = PersonalProfile.fromJson(const {});

      expect(restored.firstName, PersonalProfile.defaultProfile.firstName);
      expect(restored.tripTags, PersonalProfile.defaultProfile.tripTags);
    });
  });

  group('PrivacySettings', () {
    test('every key can be read and flipped', () {
      var settings = PrivacySettings.defaults;

      for (final key in PrivacySettingKey.values) {
        expect(settings.valueFor(key), isFalse);
        settings = settings.copyWithKey(key, true);
        expect(settings.valueFor(key), isTrue);
      }
    });

    test('copyWithKey leaves the other keys untouched', () {
      final settings = PrivacySettings.defaults.copyWithKey(
        PrivacySettingKey.offlineMode,
        true,
      );

      expect(settings.offlineMode, isTrue);
      expect(settings.privateProfile, isFalse);
      expect(settings.onlyPeopleInRadius, isFalse);
      expect(settings.checkMessages, isFalse);
    });

    test('copyWith overrides only the given fields', () {
      final settings = PrivacySettings.defaults.copyWith(checkMessages: true);

      expect(settings.checkMessages, isTrue);
      expect(settings.privateProfile, isFalse);
    });

    test('round-trips every combination through JSON', () {
      var settings = PrivacySettings.defaults;

      for (final key in PrivacySettingKey.values) {
        settings = settings.copyWithKey(key, true);
        final restored = PrivacySettings.fromJson(settings.toJson());

        for (final other in PrivacySettingKey.values) {
          expect(
            restored.valueFor(other),
            settings.valueFor(other),
            reason: 'key $other after setting $key',
          );
        }
      }
    });

    test('fromJson falls back on non-bool values and missing keys', () {
      final restored = PrivacySettings.fromJson({'privateProfile': 'yes'});

      expect(restored.privateProfile, isFalse);
      expect(restored.offlineMode, isFalse);
    });
  });

  group('ChatMessage', () {
    test('round-trips through JSON with an attachment', () {
      final message = buildMessage(
        '3',
        text: 'hi',
        sentAt: DateTime.parse('2024-01-01T10:00:00.000'),
        attachedTripId: 'trip_1',
      );

      final restored = ChatMessage.fromJson(message.toJson());

      expect(restored.id, '3');
      expect(restored.text, 'hi');
      expect(restored.isFromMe, isTrue);
      expect(restored.attachedTripId, 'trip_1');
      expect(restored.sentAt, message.sentAt);
    });

    test('round-trips a message with no attachment', () {
      final restored = ChatMessage.fromJson(
        buildMessage('4', isFromMe: false).toJson(),
      );

      expect(restored.attachedTripId, isNull);
      expect(restored.isFromMe, isFalse);
    });

    test('round-trips text containing JSON-significant characters', () {
      const text = '{"not":"json"} — "quoted", \\backslash\\';
      final restored = ChatMessage.fromJson(
        buildMessage('5', text: text).toJson(),
      );

      expect(restored.text, text);
    });

    test('fromJson tolerates missing/invalid fields', () {
      final restored = ChatMessage.fromJson(const {});

      expect(restored.id, '');
      expect(restored.text, '');
      expect(restored.isFromMe, isFalse);
      expect(restored.attachedTripId, isNull);
    });
  });

  group('SavedTripPreview', () {
    test('round-trips through JSON', () {
      final preview = buildBookmark(
        tags: [buildTag('relax', borderColor: const Color(0xFF778899))],
      );

      final restored = SavedTripPreview.fromJson(preview.toJson());

      expect(restored.tripName, 'Trip 1');
      expect(restored.destinationTitle, 'Dest');
      expect(restored.bookmarkType, SavedBookmarkType.trip);
      expect(restored.sourceId, 'trip_1');
      expect(restored.tags.single.label, 'relax');
      expect(restored.tags.single.borderColor, isNotNull);
    });

    test('round-trips a mate bookmark', () {
      final restored = SavedTripPreview.fromJson(
        buildBookmark(
          name: 'Alessia',
          sourceId: 'mate_1',
          type: SavedBookmarkType.mate,
        ).toJson(),
      );

      expect(restored.bookmarkType, SavedBookmarkType.mate);
      expect(restored.sourceId, 'mate_1');
    });

    test('infers the mate type from a "Profile:" destination title', () {
      final restored = SavedTripPreview.fromJson({
        'tripName': 'Alessia',
        'destinationTitle': 'Profile: Alessia',
        'description': 'x',
        'coverImage': '',
        'tags': const [],
      });

      expect(restored.bookmarkType, SavedBookmarkType.mate);
    });

    test('coerces non-string fields rather than dropping the record', () {
      // Storage is JSON, so a number that was written as a name comes back as
      // a num. Losing the whole bookmark over that would be worse than
      // rendering "42".
      final restored = SavedTripPreview.fromJson(const {
        'tripName': 42,
        'destinationTitle': true,
        'description': 3.5,
        'coverImage': null,
        'tags': <Object>[],
      });

      expect(restored.tripName, '42');
      expect(restored.destinationTitle, 'true');
      expect(restored.description, '3.5');
      expect(restored.coverImage, '');
    });

    test('defaults to the trip type and empty tags on missing fields', () {
      final restored = SavedTripPreview.fromJson(const {});

      expect(restored.bookmarkType, SavedBookmarkType.trip);
      expect(restored.tags, isEmpty);
      expect(restored.tripName, '');
    });

    test('parses numeric and string color values', () {
      final restored = SavedTripPreview.fromJson({
        'tripName': 't',
        'destinationTitle': 'd',
        'description': '',
        'coverImage': '',
        'bookmarkType': 'trip',
        'tags': [
          {'label': 'a', 'backgroundColor': 0xFF010203, 'textColor': '255'},
        ],
      });

      expect(restored.tags.single.label, 'a');
      expect(restored.tags.single.borderColor, isNull);
    });
  });

  group('value holders', () {
    test('TripTag keeps its colors and treats the border as optional', () {
      const tag = TripTag(
        label: 'scenic',
        backgroundColor: Color(0xFF102030),
        textColor: Color(0xFF405060),
      );

      expect(tag.label, 'scenic');
      expect(tag.backgroundColor.toARGB32(), 0xFF102030);
      expect(tag.borderColor, isNull);
    });

    test('TripTileData exposes everything a schedule screen needs', () {
      final trip = buildTrip(
        id: 'trip_7',
        label: 'Seven',
        tags: [buildTag('relax')],
      );

      expect(trip.tripId, 'trip_7');
      expect(trip.asset, 'assets/images/home/trip_7.svg');
      expect(trip.scheduleImages, ['assets/images/schedule/trip_7_1.svg']);
      expect(trip.destinationTitle, 'Destination Seven');
      expect(trip.description, 'Description of Seven');
      expect(trip.tags.single.label, 'relax');
    });

    test(
      'MateProfile list fields default to empty and the avatar is optional',
      () {
        final mate = buildMate(id: 'm1', name: 'Marco');

        expect(mate.id, 'm1');
        expect(mate.name, 'Marco');
        expect(mate.profileImageAsset, isNull);
        expect(mate.keywords, isEmpty);
        expect(mate.interests, isEmpty);
        expect(mate.preferredTrips, isEmpty);
      },
    );

    test('SearchResearchMode has exactly the two documented modes', () {
      expect(SearchResearchMode.values, [
        SearchResearchMode.trips,
        SearchResearchMode.mates,
      ]);
    });
  });
}
