import 'package:travelmate/shared/models/trip_tile_data.dart';

/// Ranks [trips] against [query]. A blank query returns the catalog as-is
/// (so mock trips are visible before the user types anything). When
/// [limit] is given, the result is capped to that many entries.
List<TripTileData> filterTrips(
  List<TripTileData> trips,
  String query, {
  int? limit,
}) {
  final normalizedQuery = query.trim().toLowerCase();

  final ranked = normalizedQuery.isEmpty
      ? trips
      : _rankTripsByQuery(trips, normalizedQuery);

  return _applyLimit(ranked, limit);
}

List<TripTileData> _rankTripsByQuery(
  List<TripTileData> trips,
  String normalizedQuery,
) {
  final terms = normalizedQuery
      .split(RegExp(r'\s+'))
      .where((term) => term.isNotEmpty)
      .toList(growable: false);

  final scoredTrips = <({TripTileData trip, int score})>[];

  for (final trip in trips) {
    final score = _scoreTrip(trip, terms);
    if (score != null) {
      scoredTrips.add((trip: trip, score: score));
    }
  }

  scoredTrips.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    return byScore != 0 ? byScore : a.trip.label.compareTo(b.trip.label);
  });

  return scoredTrips.map((entry) => entry.trip).toList(growable: false);
}

/// Returns the total score for [trip] across all [terms], or null if any
/// term fails to match (a trip must match every term to be included).
int? _scoreTrip(TripTileData trip, List<String> terms) {
  final label = trip.label.toLowerCase();
  final destination = trip.destinationTitle.toLowerCase();
  final description = trip.description.toLowerCase();
  final tagLabels = trip.tags
      .map((tag) => tag.label.toLowerCase())
      .toList(growable: false);

  var score = 0;

  for (final term in terms) {
    final termScore = _scoreTripTerm(
      term,
      label: label,
      destination: destination,
      description: description,
      tagLabels: tagLabels,
    );

    if (termScore == null) {
      return null;
    }

    score += termScore;
  }

  return score;
}

int? _scoreTripTerm(
  String term, {
  required String label,
  required String destination,
  required String description,
  required List<String> tagLabels,
}) {
  var score = 0;
  var matched = false;

  if (label.startsWith(term)) {
    score += 8;
    matched = true;
  } else if (label.contains(term)) {
    score += 5;
    matched = true;
  }

  if (destination.startsWith(term)) {
    score += 7;
    matched = true;
  } else if (destination.contains(term)) {
    score += 4;
    matched = true;
  }

  if (description.contains(term)) {
    score += 2;
    matched = true;
  }

  final matchingTag = tagLabels.firstWhere(
    (tagLabel) => tagLabel.startsWith(term) || tagLabel.contains(term),
    orElse: () => '',
  );

  if (matchingTag.isNotEmpty) {
    score += matchingTag.startsWith(term) ? 6 : 3;
    matched = true;
  }

  return matched ? score : null;
}

List<TripTileData> _applyLimit(List<TripTileData> ranked, int? limit) {
  if (limit != null && ranked.length > limit) {
    return ranked.take(limit).toList(growable: false);
  }

  return ranked;
}
