import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:travelmate/shared/data/saved_bookmarks_data.dart';
import 'package:travelmate/shared/models/saved_trip_preview.dart';

class SavedTripPreviewStore extends ValueNotifier<List<SavedTripPreview>> {
  SavedTripPreviewStore._({SavedBookmarksData? bookmarksData})
    : _bookmarksData = bookmarksData ?? const SavedBookmarksData(),
      super(const []);

  final SavedBookmarksData _bookmarksData;
  bool _initialized = false;

  static final SavedTripPreviewStore instance = SavedTripPreviewStore._();

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
    final persisted = await _bookmarksData.readAll();
    value = List<SavedTripPreview>.unmodifiable(persisted);
  }

  bool isSaved(SavedTripPreview preview) {
    return value.any((item) => _matchesEntry(item, preview));
  }

  void stageBookmark(SavedTripPreview preview) {
    final next = List<SavedTripPreview>.from(value);
    next.removeWhere((item) => _matchesEntry(item, preview));
    next.insert(0, preview);

    final snapshot = List<SavedTripPreview>.unmodifiable(next);
    value = snapshot;
    unawaited(_bookmarksData.writeAll(snapshot));
  }

  void removeBookmark(SavedTripPreview preview) {
    final next = List<SavedTripPreview>.from(value);
    next.removeWhere((item) => _matchesEntry(item, preview));

    final snapshot = List<SavedTripPreview>.unmodifiable(next);
    value = snapshot;
    unawaited(_bookmarksData.writeAll(snapshot));
  }

  bool toggleBookmark(SavedTripPreview preview) {
    if (isSaved(preview)) {
      removeBookmark(preview);
      return false;
    }

    stageBookmark(preview);
    return true;
  }

  void stageTrip(SavedTripPreview preview) {
    stageBookmark(preview);
  }

  bool _matchesEntry(SavedTripPreview item, SavedTripPreview preview) {
    if (item.bookmarkType != preview.bookmarkType) {
      return false;
    }

    final normalizedPreviewSourceId = preview.sourceId.trim().toLowerCase();
    final normalizedItemSourceId = item.sourceId.trim().toLowerCase();

    if (normalizedPreviewSourceId.isNotEmpty) {
      if (normalizedItemSourceId.isNotEmpty) {
        if (normalizedItemSourceId == normalizedPreviewSourceId) {
          return true;
        }

        // Migration support: older trip records used labels as sourceId.
        if (preview.bookmarkType == SavedBookmarkType.trip &&
            (!_isCanonicalTripId(normalizedPreviewSourceId) ||
                !_isCanonicalTripId(normalizedItemSourceId))) {
          return _normalized(item.destinationTitle) ==
              _normalized(preview.destinationTitle);
        }

        return false;
      }

      // Legacy fallback for old records saved before sourceId existed.
      if (preview.bookmarkType == SavedBookmarkType.trip) {
        return _normalized(item.destinationTitle) ==
            _normalized(preview.destinationTitle);
      }

      return _normalized(item.tripName) == _normalized(preview.tripName);
    }

    if (normalizedItemSourceId.isNotEmpty) {
      if (preview.bookmarkType == SavedBookmarkType.trip) {
        return _normalized(item.destinationTitle) ==
            _normalized(preview.destinationTitle);
      }

      return false;
    }

    if (preview.bookmarkType == SavedBookmarkType.trip) {
      return _normalized(item.destinationTitle) ==
          _normalized(preview.destinationTitle);
    }

    return _normalized(item.tripName) == _normalized(preview.tripName);
  }

  bool _isCanonicalTripId(String sourceId) {
    return RegExp(r'^trip_\d+$').hasMatch(sourceId);
  }

  String _normalized(String value) {
    return value.trim().toLowerCase();
  }
}
