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

  final ranked = normalizedQuery.isEmpty
      ? mates
      : _rankMatesByQuery(mates, normalizedQuery);

  return _applyLimit(ranked, limit);
}

List<MateProfile> _rankMatesByQuery(
  List<MateProfile> mates,
  String normalizedQuery,
) {
  final terms = normalizedQuery
      .split(RegExp(r'\s+'))
      .where((term) => term.isNotEmpty)
      .toList(growable: false);

  final scoredMates = <({MateProfile mate, int score})>[];

  for (final mate in mates) {
    final score = _scoreMate(mate, terms);
    if (score != null) {
      scoredMates.add((mate: mate, score: score));
    }
  }

  scoredMates.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    return byScore != 0 ? byScore : a.mate.name.compareTo(b.mate.name);
  });

  return scoredMates.map((entry) => entry.mate).toList(growable: false);
}

/// Returns the total score for [mate] across all [terms], or null if any
/// term fails to match (a mate must match every term to be included).
int? _scoreMate(MateProfile mate, List<String> terms) {
  final name = mate.name.toLowerCase();
  final description = mate.description.toLowerCase();
  final keywords = mate.keywords
      .map((keyword) => keyword.toLowerCase())
      .toList(growable: false);

  var score = 0;

  for (final term in terms) {
    final termScore = _scoreTerm(
      term,
      name: name,
      description: description,
      keywords: keywords,
    );

    if (termScore == null) {
      return null;
    }

    score += termScore;
  }

  return score;
}

int? _scoreTerm(
  String term, {
  required String name,
  required String description,
  required List<String> keywords,
}) {
  var score = 0;
  var matched = false;

  if (name.startsWith(term)) {
    score += 8;
    matched = true;
  } else if (name.contains(term)) {
    score += 5;
    matched = true;
  }

  if (description.contains(term)) {
    score += 3;
    matched = true;
  }

  final matchingKeyword = keywords.firstWhere(
    (keyword) => keyword.startsWith(term) || keyword.contains(term),
    orElse: () => '',
  );

  if (matchingKeyword.isNotEmpty) {
    score += matchingKeyword.startsWith(term) ? 6 : 4;
    matched = true;
  }

  return matched ? score : null;
}

List<MateProfile> _applyLimit(List<MateProfile> ranked, int? limit) {
  if (limit != null && ranked.length > limit) {
    return ranked.take(limit).toList(growable: false);
  }

  return ranked;
}
