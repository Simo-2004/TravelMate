import 'dart:convert';

import 'package:travelmate/core/database/trip_dao.dart';
import 'package:travelmate/shared/data/trip_catalog.dart';
import 'package:travelmate/shared/models/trip_tag_codec.dart';
import 'package:travelmate/shared/models/trip_tile_data.dart';

/// Named trip collections stored side by side in the same table.
class TripCollections {
  const TripCollections._();

  static const String trips = 'trips';
  static const String recents = 'recents';
}

/// Both catalog collections returned together after a load.
typedef TripCatalogData = ({
  List<TripTileData> trips,
  List<TripTileData> recents,
});

/// Persists the trip catalog to SQLite and reads it back as [TripTileData].
///
/// Trips are public, read-only content, so rows are stored in plain text (no
/// encryption). The catalog is seeded once from [TripCatalog]; afterwards the
/// database is the source of truth. Depends only on the [TripDao] abstraction,
/// so seeding and row mapping are unit-testable against an in-memory fake.
class TripRepository {
  TripRepository({
    required TripDao dao,
    List<TripTileData>? seedTrips,
    List<TripTileData>? seedRecents,
  }) : _dao = dao,
       _seedTrips = seedTrips ?? TripCatalog.trips,
       _seedRecents = seedRecents ?? TripCatalog.recents;

  final TripDao _dao;
  final List<TripTileData> _seedTrips;
  final List<TripTileData> _seedRecents;

  /// Seeds the catalog on first run only; a no-op once rows exist.
  Future<void> ensureSeeded() async {
    if (await _dao.countTrips() > 0) {
      return;
    }

    await _dao.insertTrips([
      ..._rowsFor(_seedTrips, TripCollections.trips),
      ..._rowsFor(_seedRecents, TripCollections.recents),
    ]);
  }

  /// Loads both collections from the database, preserving stored order.
  Future<TripCatalogData> loadCollections() async {
    return (
      trips: await _readCollection(TripCollections.trips),
      recents: await _readCollection(TripCollections.recents),
    );
  }

  List<Map<String, Object?>> _rowsFor(
    List<TripTileData> trips,
    String collection,
  ) {
    return List.generate(
      trips.length,
      (index) => _toRow(trips[index], collection, index),
    );
  }

  Map<String, Object?> _toRow(
    TripTileData trip,
    String collection,
    int position,
  ) {
    return {
      'trip_id': trip.tripId,
      'collection': collection,
      'position': position,
      'asset': trip.asset,
      'label': trip.label,
      'schedule_images': jsonEncode(trip.scheduleImages),
      'tags': jsonEncode(TripTagCodec.encodeList(trip.tags)),
      'destination_title': trip.destinationTitle,
      'description': trip.description,
    };
  }

  Future<List<TripTileData>> _readCollection(String collection) async {
    final rows = await _dao.readTripsByCollection(collection);
    return rows.map(_fromRow).toList(growable: false);
  }

  TripTileData _fromRow(Map<String, Object?> row) {
    return TripTileData(
      tripId: row['trip_id']! as String,
      asset: row['asset']! as String,
      label: row['label']! as String,
      scheduleImages: _decodeStringList(row['schedule_images']),
      tags: TripTagCodec.decodeList(jsonDecode(row['tags']! as String)),
      destinationTitle: row['destination_title']! as String,
      description: row['description']! as String,
    );
  }

  List<String> _decodeStringList(Object? value) {
    final decoded = jsonDecode(value! as String);
    if (decoded is! List) {
      return const <String>[];
    }

    return decoded.whereType<String>().toList(growable: false);
  }
}
