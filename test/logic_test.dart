import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/shared/data/mate_catalog.dart';
import 'package:travelmate/shared/data/trip_catalog.dart';
import 'package:travelmate/shared/data/trip_media_catalog.dart';
import 'package:travelmate/shared/data/trip_tag_catalog.dart';
import 'package:travelmate/shared/models/chat_message.dart';
import 'package:travelmate/shared/models/mate_profile.dart';
import 'package:travelmate/shared/models/personal_profile.dart';
import 'package:travelmate/shared/models/privacy_settings.dart';
import 'package:travelmate/shared/models/saved_trip_preview.dart';
import 'package:travelmate/shared/models/search_research_mode.dart';
import 'package:travelmate/shared/models/trip_tag.dart';
import 'package:travelmate/shared/models/trip_tile_data.dart';
import 'package:travelmate/shared/utils/chat_auto_reply.dart';
import 'package:travelmate/shared/utils/mate_search.dart';
import 'package:travelmate/shared/utils/trip_invite.dart';
import 'package:travelmate/shared/utils/trip_search.dart';

TripTileData _trip({
  required String id,
  required String label,
  required String destination,
  required String description,
  List<String> tagLabels = const [],
}) {
  return TripTileData(
    tripId: id,
    asset: 'assets/images/home/$id.svg',
    label: label,
    scheduleImages: const [],
    tags: tagLabels
        .map(
          (label) => TripTag(
            label: label,
            backgroundColor: const Color(0xFF000000),
            textColor: const Color(0xFFFFFFFF),
          ),
        )
        .toList(),
    destinationTitle: destination,
    description: description,
  );
}

MateProfile _mate({
  required String id,
  required String name,
  String description = '',
  List<String> interests = const [],
  List<String> preferredTrips = const [],
  List<String> keywords = const [],
}) {
  return MateProfile(
    id: id,
    name: name,
    description: description,
    interests: interests,
    preferredTrips: preferredTrips,
    keywords: keywords,
  );
}

void main() {
  group('filterTrips', () {
    final trips = [
      _trip(
        id: 'trip_1',
        label: 'Beach Escape',
        destination: 'Bali',
        description: 'A relaxing island getaway',
        tagLabels: ['relax-mode', 'island-vibe'],
      ),
      _trip(
        id: 'trip_2',
        label: 'Mountain Hike',
        destination: 'Alps',
        description: 'Adventure in the mountains',
        tagLabels: ['adventure', 'outdoor'],
      ),
    ];

    test('blank query returns all trips', () {
      expect(filterTrips(trips, ''), hasLength(2));
      expect(filterTrips(trips, '   '), hasLength(2));
    });

    test('limit caps blank-query results', () {
      expect(filterTrips(trips, '', limit: 1), hasLength(1));
    });

    test('matches by label prefix and ranks it first', () {
      final result = filterTrips(trips, 'beach');
      expect(result, hasLength(1));
      expect(result.first.tripId, 'trip_1');
    });

    test('matches by destination', () {
      final result = filterTrips(trips, 'alps');
      expect(result.single.tripId, 'trip_2');
    });

    test('matches by description token', () {
      final result = filterTrips(trips, 'relaxing');
      expect(result.single.tripId, 'trip_1');
    });

    test('matches by tag label', () {
      final result = filterTrips(trips, 'adventure');
      expect(result.single.tripId, 'trip_2');
    });

    test('multi-term requires all terms to match', () {
      expect(filterTrips(trips, 'mountain adventure'), hasLength(1));
      expect(filterTrips(trips, 'mountain beach'), isEmpty);
    });

    test('no match returns empty', () {
      expect(filterTrips(trips, 'zzzzz'), isEmpty);
    });

    test('limit caps ranked results', () {
      final many = [
        _trip(
          id: 't1',
          label: 'Trip one',
          destination: 'X',
          description: 'trip',
        ),
        _trip(
          id: 't2',
          label: 'Trip two',
          destination: 'Y',
          description: 'trip',
        ),
        _trip(
          id: 't3',
          label: 'Trip three',
          destination: 'Z',
          description: 'trip',
        ),
      ];
      expect(filterTrips(many, 'trip', limit: 2), hasLength(2));
    });
  });

  group('filterMates', () {
    final mates = [
      _mate(
        id: 'm1',
        name: 'Alessia',
        description: 'Loves the beach',
        keywords: ['budget', 'island'],
      ),
      _mate(
        id: 'm2',
        name: 'Marco',
        description: 'Mountain hiker',
        keywords: ['hiking', 'nature'],
      ),
    ];

    test('blank query returns all mates', () {
      expect(filterMates(mates, ''), hasLength(2));
    });

    test('blank query respects limit', () {
      expect(filterMates(mates, '', limit: 1), hasLength(1));
    });

    test('matches by name prefix', () {
      expect(filterMates(mates, 'ale').single.id, 'm1');
    });

    test('matches by description', () {
      expect(filterMates(mates, 'hiker').single.id, 'm2');
    });

    test('matches by keyword', () {
      expect(filterMates(mates, 'island').single.id, 'm1');
    });

    test('multi-term requires all', () {
      expect(filterMates(mates, 'marco mountain'), hasLength(1));
      expect(filterMates(mates, 'marco beach'), isEmpty);
    });

    test('no match returns empty', () {
      expect(filterMates(mates, 'qqqq'), isEmpty);
    });
  });

  group('resolveAutoReply', () {
    test('empty text returns fallback', () {
      expect(resolveAutoReply('  '), AppStrings.chatFallbackReply);
    });

    test('greeting keyword', () {
      expect(resolveAutoReply('Hello there'), AppStrings.chatReplyGreeting);
    });

    test('how are you takes priority over greeting', () {
      expect(resolveAutoReply('hi, how are you?'), AppStrings.chatReplyHowAreYou);
    });

    test('travel keyword', () {
      expect(resolveAutoReply('I love to travel'), AppStrings.chatReplyTravelPlans);
    });

    test('goodbye keyword', () {
      expect(resolveAutoReply('goodbye for now'), AppStrings.chatReplyGoodbye);
    });

    test('agreement keyword matches before goodbye', () {
      expect(resolveAutoReply('ok bye'), AppStrings.chatReplyAgreement);
    });

    test('whole-word matching avoids false positives', () {
      // "hi" should not match inside "this"
      expect(resolveAutoReply('think about this'), AppStrings.chatFallbackReply);
    });

    test('unknown text returns fallback', () {
      expect(resolveAutoReply('xyzzy'), AppStrings.chatFallbackReply);
    });
  });

  group('mateLikesTrip', () {
    final trip = _trip(
      id: 'trip_x',
      label: 'X',
      destination: 'X',
      description: 'X',
      tagLabels: ['island-vibe', 'relax-mode'],
    );

    test('accepts when a tag matches a preferred trip', () {
      final mate = _mate(id: 'm', name: 'M', preferredTrips: ['island-vibe']);
      expect(mateLikesTrip(mate, trip), isTrue);
    });

    test('accepts when a tag matches an interest', () {
      final mate = _mate(id: 'm', name: 'M', interests: ['relax-mode']);
      expect(mateLikesTrip(mate, trip), isTrue);
    });

    test('declines when no tag matches', () {
      final mate = _mate(id: 'm', name: 'M', interests: ['culture']);
      expect(mateLikesTrip(mate, trip), isFalse);
    });

    test('matching is case-insensitive', () {
      final mate = _mate(id: 'm', name: 'M', preferredTrips: ['ISLAND-VIBE']);
      expect(mateLikesTrip(mate, trip), isTrue);
    });
  });

  group('SavedTripPreview', () {
    final preview = SavedTripPreview(
      tripName: 'Trip 1',
      destinationTitle: 'Bali',
      description: 'Nice',
      coverImage: 'cover.svg',
      tags: const [
        TripTag(
          label: 'relax',
          backgroundColor: Color(0xFF112233),
          textColor: Color(0xFF445566),
          borderColor: Color(0xFF778899),
        ),
      ],
      bookmarkType: SavedBookmarkType.trip,
      sourceId: 'trip_1',
    );

    test('round-trips through JSON', () {
      final json = preview.toJson();
      final restored = SavedTripPreview.fromJson(json);
      expect(restored.tripName, 'Trip 1');
      expect(restored.destinationTitle, 'Bali');
      expect(restored.bookmarkType, SavedBookmarkType.trip);
      expect(restored.sourceId, 'trip_1');
      expect(restored.tags.single.label, 'relax');
      expect(restored.tags.single.borderColor, isNotNull);
    });

    test('infers mate type from Profile: destination title', () {
      final restored = SavedTripPreview.fromJson({
        'tripName': 'Alessia',
        'destinationTitle': 'Profile: Alessia',
        'description': 'x',
        'coverImage': '',
        'tags': const [],
      });
      expect(restored.bookmarkType, SavedBookmarkType.mate);
    });

    test('defaults to trip type and empty tags on missing fields', () {
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
      expect(restored.tags.single.borderColor, isNull);
    });
  });

  group('PersonalProfile', () {
    test('fullName joins first and last', () {
      const p = PersonalProfile(
        firstName: 'Anna',
        lastName: 'Bianchi',
        description: 'd',
        photoAsset: 'a.svg',
      );
      expect(p.fullName, 'Anna Bianchi');
    });

    test('fullName falls back when empty', () {
      const p = PersonalProfile(
        firstName: '',
        lastName: '',
        description: 'd',
        photoAsset: 'a.svg',
      );
      expect(p.fullName, 'Traveler profile');
    });

    test('copyWith overrides only given fields', () {
      final updated = PersonalProfile.defaultProfile.copyWith(
        firstName: 'Zoe',
      );
      expect(updated.firstName, 'Zoe');
      expect(updated.lastName, PersonalProfile.defaultProfile.lastName);
    });

    test('round-trips through JSON', () {
      final json = PersonalProfile.defaultProfile.toJson();
      final restored = PersonalProfile.fromJson(json);
      expect(restored.firstName, PersonalProfile.defaultProfile.firstName);
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

    test('fromJson dedupes and trims list entries', () {
      final restored = PersonalProfile.fromJson({
        'tripTags': ['  a ', 'a', 'b', ''],
      });
      expect(restored.tripTags, ['a', 'b']);
    });
  });

  group('PrivacySettings', () {
    test('valueFor and copyWithKey cover every key', () {
      var settings = PrivacySettings.defaults;
      for (final key in PrivacySettingKey.values) {
        expect(settings.valueFor(key), isFalse);
        settings = settings.copyWithKey(key, true);
        expect(settings.valueFor(key), isTrue);
      }
    });

    test('round-trips through JSON', () {
      const settings = PrivacySettings(
        privateProfile: true,
        onlyPeopleInRadius: false,
        checkMessages: true,
        offlineMode: false,
      );
      final restored = PrivacySettings.fromJson(settings.toJson());
      expect(restored.privateProfile, isTrue);
      expect(restored.checkMessages, isTrue);
      expect(restored.offlineMode, isFalse);
    });

    test('fromJson falls back on non-bool values', () {
      final restored = PrivacySettings.fromJson({'privateProfile': 'yes'});
      expect(restored.privateProfile, isFalse);
    });
  });

  group('ChatMessage', () {
    test('round-trips through JSON with attachment', () {
      final message = ChatMessage(
        id: '3',
        text: 'hi',
        isFromMe: true,
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

    test('fromJson tolerates missing/invalid fields', () {
      final restored = ChatMessage.fromJson(const {});
      expect(restored.id, '');
      expect(restored.text, '');
      expect(restored.isFromMe, isFalse);
      expect(restored.attachedTripId, isNull);
    });
  });

  group('catalogs', () {
    test('SearchResearchMode has two modes', () {
      expect(SearchResearchMode.values, hasLength(2));
    });

    test('TripTagCatalog resolves known labels case-insensitively', () {
      expect(TripTagCatalog.resolve('adventure'), isNotNull);
      expect(TripTagCatalog.resolve('  ADVENTURE '), isNotNull);
      expect(TripTagCatalog.resolve('does-not-exist'), isNull);
      expect(TripTagCatalog.all, isNotEmpty);
    });

    test('TripCatalog builds trips and finds by id', () {
      expect(TripCatalog.trips, hasLength(TripMediaCatalog.tripCount));
      expect(TripCatalog.recents, isNotEmpty);
      expect(TripCatalog.findTripById('trip_1'), isNotNull);
      expect(TripCatalog.findTripById('  TRIP_1 '), isNotNull);
      expect(TripCatalog.findTripById('nope'), isNull);
      expect(TripCatalog.findTripById(''), isNull);
    });

    test('TripMediaCatalog builds asset lists', () {
      expect(TripMediaCatalog.homeTripAssets, hasLength(8));
      expect(
        TripMediaCatalog.scheduleAssets,
        hasLength(TripMediaCatalog.tripCount * TripMediaCatalog.schedulePerTrip),
      );
      expect(TripMediaCatalog.scheduleSets, hasLength(8));
      expect(TripMediaCatalog.scheduleSets.first, hasLength(4));
    });

    test('MateCatalog exposes mock mates', () {
      expect(MateCatalog.mates, isNotEmpty);
      expect(MateCatalog.mates.first.name, isNotEmpty);
    });
  });
}
