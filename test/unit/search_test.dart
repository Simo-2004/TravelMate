/// Unit testing — the search ranking functions.
///
/// [filterTrips] and [filterMates] are pure top-level functions: same input,
/// same output, no state and no dependencies. That makes them the smallest
/// testable units in the app, and they are tested here in complete isolation.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/shared/utils/mate_search.dart';
import 'package:travelmate/shared/utils/trip_search.dart';

import '../helpers/fixtures.dart';

void main() {
  group('filterTrips', () {
    final trips = [
      buildTaggedTrip(
        id: 'trip_1',
        label: 'Beach Escape',
        destinationTitle: 'Bali',
        description: 'A relaxing island getaway',
        tagLabels: ['relax-mode', 'island-vibe'],
      ),
      buildTaggedTrip(
        id: 'trip_2',
        label: 'Mountain Hike',
        destinationTitle: 'Alps',
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
      expect(filterTrips(trips, 'alps').single.tripId, 'trip_2');
    });

    test('matches by description token', () {
      expect(filterTrips(trips, 'relaxing').single.tripId, 'trip_1');
    });

    test('matches by tag label', () {
      expect(filterTrips(trips, 'adventure').single.tripId, 'trip_2');
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
        buildTaggedTrip(id: 't1', label: 'Trip one', description: 'trip'),
        buildTaggedTrip(id: 't2', label: 'Trip two', description: 'trip'),
        buildTaggedTrip(id: 't3', label: 'Trip three', description: 'trip'),
      ];
      expect(filterTrips(many, 'trip', limit: 2), hasLength(2));
    });

    test('an empty catalog yields no results for any query', () {
      expect(filterTrips(const [], 'beach'), isEmpty);
      expect(filterTrips(const [], ''), isEmpty);
    });

    test('matching ignores case and surrounding whitespace', () {
      expect(filterTrips(trips, '  BEACH  ').single.tripId, 'trip_1');
    });
  });

  group('filterMates', () {
    final mates = [
      buildMate(
        id: 'm1',
        name: 'Alessia',
        description: 'Loves the beach',
        keywords: ['budget', 'island'],
      ),
      buildMate(
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

    test('an empty catalog yields no results for any query', () {
      expect(filterMates(const [], 'alessia'), isEmpty);
    });
  });
}
