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

  final List<TripTileData> ranked;
  if (normalizedQuery.isEmpty) {
    ranked = trips;
  } else {
    final terms = normalizedQuery
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty)
        .toList(growable: false);

    final scoredTrips = <({TripTileData trip, int score})>[];

    for (final trip in trips) {
      final label = trip.label.toLowerCase();
      final destination = trip.destinationTitle.toLowerCase();
      final description = trip.description.toLowerCase();
      final tagLabels = trip.tags
          .map((tag) => tag.label.toLowerCase())
          .toList(growable: false);

      var score = 0;
      var matchesAllTerms = true;

      for (final term in terms) {
        var termMatched = false;

        if (label.startsWith(term)) {
          score += 8;
          termMatched = true;
        } else if (label.contains(term)) {
          score += 5;
          termMatched = true;
        }

        if (destination.startsWith(term)) {
          score += 7;
          termMatched = true;
        } else if (destination.contains(term)) {
          score += 4;
          termMatched = true;
        }

        if (description.contains(term)) {
          score += 2;
          termMatched = true;
        }

        final matchingTag = tagLabels.firstWhere(
          (tagLabel) => tagLabel.startsWith(term) || tagLabel.contains(term),
          orElse: () => '',
        );
        if (matchingTag.isNotEmpty) {
          score += matchingTag.startsWith(term) ? 6 : 3;
          termMatched = true;
        }

        if (!termMatched) {
          matchesAllTerms = false;
          break;
        }
      }

      if (matchesAllTerms) {
        scoredTrips.add((trip: trip, score: score));
      }
    }

    scoredTrips.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) {
        return byScore;
      }

      return a.trip.label.compareTo(b.trip.label);
    });

    ranked = scoredTrips.map((entry) => entry.trip).toList(growable: false);
  }

  if (limit != null && ranked.length > limit) {
    return ranked.take(limit).toList(growable: false);
  }

  return ranked;
}
