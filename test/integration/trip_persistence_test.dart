/// Integration testing — the trip catalog persistence stack.
///
/// TripRepository -> TripDao, plus the tag codec that turns styled tags into a
/// single storable column. Trip data is public content, so unlike the profile
/// and chat stacks it is stored in the clear; what matters here is that
/// seeding happens exactly once and that ordering, tags and image lists all
/// survive the round trip.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/shared/data/trip_catalog.dart';
import 'package:travelmate/shared/data/trip_repository.dart';

import '../helpers/fakes.dart';
import '../helpers/fixtures.dart';

void main() {
  TripRepository buildRepository(FakeTripDao dao) {
    return TripRepository(
      dao: dao,
      seedTrips: [
        buildTrip(
          id: 'trip_1',
          label: 'A',
          tags: [buildTag('relax', borderColor: const Color(0xFF778899))],
        ),
        buildTrip(id: 'trip_2', label: 'B'),
      ],
      seedRecents: [buildTrip(id: 'trip_1', label: 'Recent A')],
    );
  }

  group('seeding', () {
    test('seeds both collections on the first run only', () async {
      final dao = FakeTripDao();
      final repository = buildRepository(dao);

      await repository.ensureSeeded();
      expect(dao.rows, hasLength(3));

      // Second call is a no-op because rows already exist.
      await repository.ensureSeeded();
      expect(dao.rows, hasLength(3));
    });

    test('defaults to the real TripCatalog when no seed is given', () async {
      final dao = FakeTripDao();

      await TripRepository(dao: dao).ensureSeeded();

      expect(
        dao.rows,
        hasLength(TripCatalog.trips.length + TripCatalog.recents.length),
      );
    });

    test('a repository over an empty seed writes nothing', () async {
      final dao = FakeTripDao();

      await TripRepository(
        dao: dao,
        seedTrips: const [],
        seedRecents: const [],
      ).ensureSeeded();

      expect(dao.rows, isEmpty);
    });
  });

  group('loading', () {
    test('loads collections preserving order, tags and images', () async {
      final dao = FakeTripDao();
      final repository = buildRepository(dao);
      await repository.ensureSeeded();

      final loaded = await repository.loadCollections();

      expect(loaded.trips.map((trip) => trip.label), ['A', 'B']);
      expect(loaded.recents.map((trip) => trip.label), ['Recent A']);

      final first = loaded.trips.first;
      expect(first.tripId, 'trip_1');
      expect(first.scheduleImages, ['assets/images/schedule/trip_1_1.svg']);
      expect(first.tags.single.label, 'relax');
      expect(first.tags.single.borderColor?.toARGB32(), 0xFF778899);
    });

    test('the two collections stay separate', () async {
      final dao = FakeTripDao();
      final repository = buildRepository(dao);
      await repository.ensureSeeded();

      final loaded = await repository.loadCollections();

      expect(loaded.trips, hasLength(2));
      expect(loaded.recents, hasLength(1));
    });

    test('loading before seeding yields empty collections', () async {
      final loaded = await buildRepository(FakeTripDao()).loadCollections();

      expect(loaded.trips, isEmpty);
      expect(loaded.recents, isEmpty);
    });

    test(
      'the whole real catalog survives a seed-and-load round trip',
      () async {
        final repository = TripRepository(dao: FakeTripDao());
        await repository.ensureSeeded();

        final loaded = await repository.loadCollections();

        expect(loaded.trips, hasLength(TripCatalog.trips.length));
        expect(
          loaded.trips.map((trip) => trip.tripId),
          TripCatalog.trips.map((trip) => trip.tripId),
        );
      },
    );
  });
}
