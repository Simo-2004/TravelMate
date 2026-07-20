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

    final previewSourceId = preview.sourceId.trim().toLowerCase();
    final itemSourceId = item.sourceId.trim().toLowerCase();

    if (previewSourceId.isEmpty) {
      // Legacy fallback for old records saved before sourceId existed.
      return itemSourceId.isEmpty
          ? _matchesLegacyKey(item, preview)
          : _matchesDestinationOnly(item, preview);
    }

    if (itemSourceId.isEmpty) {
      return _matchesLegacyKey(item, preview);
    }

    if (itemSourceId == previewSourceId) {
      return true;
    }

    return _matchesMigratedTripTitle(item, preview, previewSourceId, itemSourceId);
  }

  // Migration support: older trip records used labels as sourceId.
  bool _matchesMigratedTripTitle(
    SavedTripPreview item,
    SavedTripPreview preview,
    String previewSourceId,
    String itemSourceId,
  ) {
    final isMigratedTripRecord =
        preview.bookmarkType == SavedBookmarkType.trip &&
        (!_isCanonicalTripId(previewSourceId) ||
            !_isCanonicalTripId(itemSourceId));

    return isMigratedTripRecord &&
        _normalized(item.destinationTitle) ==
            _normalized(preview.destinationTitle);
  }

  bool _matchesLegacyKey(SavedTripPreview item, SavedTripPreview preview) {
    if (preview.bookmarkType == SavedBookmarkType.trip) {
      return _normalized(item.destinationTitle) ==
          _normalized(preview.destinationTitle);
    }

    return _normalized(item.tripName) == _normalized(preview.tripName);
  }

  bool _matchesDestinationOnly(SavedTripPreview item, SavedTripPreview preview) {
    return preview.bookmarkType == SavedBookmarkType.trip &&
        _normalized(item.destinationTitle) ==
            _normalized(preview.destinationTitle);
  }

  bool _isCanonicalTripId(String sourceId) {
    return RegExp(r'^trip_\d+$').hasMatch(sourceId);
  }

  String _normalized(String value) {
    return value.trim().toLowerCase();
  }
}
