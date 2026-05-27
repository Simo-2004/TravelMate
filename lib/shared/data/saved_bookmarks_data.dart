import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelmate/shared/models/saved_trip_preview.dart';

class SavedBookmarksData {
  static const String _storageKey = 'saved_bookmarks_v1';

  const SavedBookmarksData();

  Future<List<SavedTripPreview>> readAll() async {
    final preferences = await SharedPreferences.getInstance();
    final serialized = preferences.getString(_storageKey);

    if (serialized == null || serialized.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(serialized);
      if (decoded is! List) {
        return const [];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) =>
                SavedTripPreview.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> writeAll(List<SavedTripPreview> items) async {
    final preferences = await SharedPreferences.getInstance();
    final serialized = jsonEncode(
      items.map((item) => item.toJson()).toList(growable: false),
    );
    await preferences.setString(_storageKey, serialized);
  }
}
