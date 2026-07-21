import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/core/database/trip_dao.dart';
import 'package:travelmate/shared/data/trip_catalog.dart';
import 'package:travelmate/shared/data/trip_repository.dart';
import 'package:travelmate/shared/models/trip_tag.dart';
import 'package:travelmate/shared/models/trip_tag_codec.dart';
import 'package:travelmate/shared/models/trip_tile_data.dart';
import 'package:travelmate/shared/state/trip_store.dart';

/// In-memory [TripDao] so repository logic runs without a native SQLite engine.
class _FakeTripDao implements TripDao {
  final List<Map<String, Object?>> rows = [];

  @override
  Future<int> countTrips() async => rows.length;

  @override
  Future<void> insertTrips(List<Map<String, Object?>> newRows) async {
    rows.addAll(newRows.map(Map<String, Object?>.from));
  }

  @override
  Future<List<Map<String, Object?>>> readTripsByCollection(
    String collection,
  ) async {
    final matching =
        rows.where((row) => row['collection'] == collection).toList()
          ..sort(
            (a, b) => (a['position']! as int).compareTo(b['position']! as int),
          );
    return matching;
  }
}

TripTileData _trip(String id, String label) {
  return TripTileData(
    tripId: id,
    asset: 'assets/images/home/$id.svg',
    label: label,
    scheduleImages: ['assets/images/schedule/${id}_1.svg'],
    tags: const [
      TripTag(
        label: 'relax',
        backgroundColor: Color(0xFF112233),
        textColor: Color(0xFF445566),
        borderColor: Color(0xFF778899),
      ),
    ],
    destinationTitle: 'Destination $label',
    description: 'Description of $label',
  );
}

void main() {
  group('TripTagCodec', () {
    test('round-trips a tag with and without a border color', () {
      const withBorder = TripTag(
        label: 'scenic',
        backgroundColor: Color(0xFF102030),
        textColor: Color(0xFF405060),
        borderColor: Color(0xFF708090),
      );
      const noBorder = TripTag(
        label: 'budget',
        backgroundColor: Color(0xFF010203),
        textColor: Color(0xFF040506),
      );

      final decoded = TripTagCodec.decodeList(
        TripTagCodec.encodeList([withBorder, noBorder]),
      );

      expect(decoded, hasLength(2));
      expect(decoded[0].label, 'scenic');
      expect(decoded[0].backgroundColor.toARGB32(), 0xFF102030);
      expect(decoded[0].borderColor?.toARGB32(), 0xFF708090);
      expect(decoded[1].label, 'budget');
      expect(decoded[1].borderColor, isNull);
    });

    test('decodeList returns empty for a non-list', () {
      expect(TripTagCodec.decodeList('nope'), isEmpty);
      expect(TripTagCodec.decodeList(null), isEmpty);
    });

    test('fromJson falls back for missing/invalid colors', () {
      final tag = TripTagCodec.fromJson({'label': 'x'});

      expect(tag.label, 'x');
      expect(tag.backgroundColor.toARGB32(), 0xFFFFF700);
      expect(tag.textColor.toARGB32(), 0xFF3A3200);
      expect(tag.borderColor, isNull);
    });
  });

  group('TripRepository', () {
    test('seeds both collections on first run only', () async {
      final dao = _FakeTripDao();
      final repository = TripRepository(
        dao: dao,
        seedTrips: [_trip('trip_1', 'A'), _trip('trip_2', 'B')],
        seedRecents: [_trip('trip_1', 'Recent A')],
      );

      await repository.ensureSeeded();
      expect(dao.rows, hasLength(3));

      // Second call is a no-op because rows already exist.
      await repository.ensureSeeded();
      expect(dao.rows, hasLength(3));
    });

    test('loads collections preserving order, tags and images', () async {
      final dao = _FakeTripDao();
      final repository = TripRepository(
        dao: dao,
        seedTrips: [_trip('trip_1', 'A'), _trip('trip_2', 'B')],
        seedRecents: [_trip('trip_1', 'Recent A')],
      );
      await repository.ensureSeeded();

      final loaded = await repository.loadCollections();

      expect(loaded.trips.map((t) => t.label), ['A', 'B']);
      expect(loaded.recents.map((t) => t.label), ['Recent A']);

      final first = loaded.trips.first;
      expect(first.tripId, 'trip_1');
      expect(first.scheduleImages, ['assets/images/schedule/trip_1_1.svg']);
      expect(first.tags.single.label, 'relax');
      expect(first.tags.single.borderColor?.toARGB32(), 0xFF778899);
    });

    test('defaults to the real TripCatalog when no seed is given', () async {
      final dao = _FakeTripDao();
      final repository = TripRepository(dao: dao);

      await repository.ensureSeeded();

      expect(
        dao.rows,
        hasLength(TripCatalog.trips.length + TripCatalog.recents.length),
      );
    });
  });

  group('TripStore', () {
    test('initialize seeds, loads and exposes lookups', () async {
      final dao = _FakeTripDao();
      final store = TripStore.withRepository(
        TripRepository(
          dao: dao,
          seedTrips: [_trip('trip_1', 'A'), _trip('trip_2', 'B')],
          seedRecents: [_trip('trip_1', 'Recent A')],
        ),
      );

      await store.initialize();
      await store.initialize(); // idempotent

      expect(store.trips.map((t) => t.label), ['A', 'B']);
      expect(store.recents.single.label, 'Recent A');
      expect(store.findTripById('trip_2')!.label, 'B');
      expect(store.findTripById('  TRIP_1 ')!.tripId, 'trip_1');
      expect(store.findTripById(''), isNull);
      expect(store.findTripById('missing'), isNull);
    });

    test('debugSetData replaces the in-memory catalog', () {
      final store = TripStore.withRepository(
        TripRepository(dao: _FakeTripDao()),
      );

      store.debugSetData(
        trips: [_trip('trip_9', 'Nine')],
        recents: const [],
      );

      expect(store.findTripById('trip_9')!.label, 'Nine');
      expect(store.recents, isEmpty);
    });
  });
}
