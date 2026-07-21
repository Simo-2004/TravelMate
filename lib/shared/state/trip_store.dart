import 'package:flutter/foundation.dart';

import 'package:travelmate/core/database/trip_sqflite_dao.dart';
import 'package:travelmate/shared/data/trip_repository.dart';
import 'package:travelmate/shared/models/trip_tile_data.dart';

/// In-memory cache of the trip catalog, backed by SQLite.
///
/// Unlike the (mutable) profile store this is not a [ValueNotifier]: the
/// catalog is read-only, so it is loaded once at startup and then served
/// synchronously — keeping existing callers (including the synchronous
/// [findTripById] used inside chat widgets) unchanged.
class TripStore {
  TripStore._({TripRepository? repository})
    : _repository = repository ?? TripRepository(dao: TripSqfliteDao());

  /// Test-only constructor that injects a repository (typically backed by a
  /// fake DAO), so `initialize()` can be exercised without a live database.
  @visibleForTesting
  factory TripStore.withRepository(TripRepository repository) {
    return TripStore._(repository: repository);
  }

  final TripRepository _repository;
  bool _initialized = false;

  List<TripTileData> _trips = const [];
  List<TripTileData> _recents = const [];
  Map<String, TripTileData> _tripById = const {};

  static final TripStore instance = TripStore._();

  List<TripTileData> get trips => _trips;

  List<TripTileData> get recents => _recents;

  /// Seeds the database on first run, then loads both collections into memory.
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
    await _repository.ensureSeeded();
    final loaded = await _repository.loadCollections();
    _apply(trips: loaded.trips, recents: loaded.recents);
  }

  /// Synchronous lookup over the loaded `trips` collection (mirrors the old
  /// `TripCatalog.findTripById`). Returns null for blank or unknown ids.
  TripTileData? findTripById(String tripId) {
    final normalized = tripId.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    return _tripById[normalized];
  }

  void _apply({
    required List<TripTileData> trips,
    required List<TripTileData> recents,
  }) {
    _trips = trips;
    _recents = recents;
    _tripById = {
      for (final trip in trips) trip.tripId.trim().toLowerCase(): trip,
    };
  }

  /// Test-only seam: loads the catalog directly (no database / plugins), so
  /// widget tests that read trips don't need a live SQLite engine.
  @visibleForTesting
  void debugSetData({
    required List<TripTileData> trips,
    required List<TripTileData> recents,
  }) {
    _apply(trips: trips, recents: recents);
    _initialized = true;
  }
}
