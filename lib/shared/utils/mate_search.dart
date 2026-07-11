import 'package:travelmate/shared/models/mate_profile.dart';

/// Ranks [mates] against [query]. A blank query returns the catalog as-is
/// (so mock profiles are visible before the user types anything). When
/// [limit] is given, the result is capped to that many entries.
List<MateProfile> filterMates(
  List<MateProfile> mates,
  String query, {
  int? limit,
}) {
  final normalizedQuery = query.trim().toLowerCase();

  final List<MateProfile> ranked;
  if (normalizedQuery.isEmpty) {
    ranked = mates;
  } else {
    final terms = normalizedQuery
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty)
        .toList(growable: false);

    final scoredMates = <({MateProfile mate, int score})>[];

    for (final mate in mates) {
      final name = mate.name.toLowerCase();
      final description = mate.description.toLowerCase();
      final keywords = mate.keywords
          .map((keyword) => keyword.toLowerCase())
          .toList(growable: false);

      var score = 0;
      var matchesAllTerms = true;

      for (final term in terms) {
        var termMatched = false;

        if (name.startsWith(term)) {
          score += 8;
          termMatched = true;
        } else if (name.contains(term)) {
          score += 5;
          termMatched = true;
        }

        if (description.contains(term)) {
          score += 3;
          termMatched = true;
        }

        final matchingKeyword = keywords.firstWhere(
          (keyword) => keyword.startsWith(term) || keyword.contains(term),
          orElse: () => '',
        );

        if (matchingKeyword.isNotEmpty) {
          score += matchingKeyword.startsWith(term) ? 6 : 4;
          termMatched = true;
        }

        if (!termMatched) {
          matchesAllTerms = false;
          break;
        }
      }

      if (matchesAllTerms) {
        scoredMates.add((mate: mate, score: score));
      }
    }

    scoredMates.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) {
        return byScore;
      }

      return a.mate.name.compareTo(b.mate.name);
    });

    ranked = scoredMates.map((entry) => entry.mate).toList(growable: false);
  }

  if (limit != null && ranked.length > limit) {
    return ranked.take(limit).toList(growable: false);
  }

  return ranked;
}
