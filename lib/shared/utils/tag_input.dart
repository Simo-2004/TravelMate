/// Pure helpers for editing free-text tag lists (interests, trip tags).
///
/// Shared by the profile editor and the account-creation form so the
/// normalize/dedupe/add/remove rules live in one place instead of being
/// copy-pasted per screen.
class TagInput {
  const TagInput._();

  /// Trims and collapses internal whitespace runs to single spaces.
  static String normalizeLabel(String raw) {
    return raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Normalizes every entry and drops blanks and case-insensitive duplicates,
  /// preserving order and the first-seen casing.
  static List<String> clean(List<String> source) {
    final seen = <String>{};
    final cleaned = <String>[];

    for (final item in source) {
      final normalized = normalizeLabel(item);
      if (normalized.isEmpty) {
        continue;
      }
      if (seen.add(normalized.toLowerCase())) {
        cleaned.add(normalized);
      }
    }

    return cleaned;
  }

  /// Returns [current] with [raw] appended, or null when [raw] is blank or a
  /// case-insensitive duplicate (i.e. nothing should change).
  static List<String>? tryAdd(List<String> current, String raw) {
    final normalized = normalizeLabel(raw);
    if (normalized.isEmpty) {
      return null;
    }
    if (current.any((tag) => tag.toLowerCase() == normalized.toLowerCase())) {
      return null;
    }

    return [...current, normalized];
  }

  /// Returns [current] without the entry matching [label] (case-insensitive).
  static List<String> remove(List<String> current, String label) {
    return current
        .where((tag) => tag.toLowerCase() != label.toLowerCase())
        .toList(growable: false);
  }
}
