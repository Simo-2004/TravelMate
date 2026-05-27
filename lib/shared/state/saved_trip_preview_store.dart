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

  void stageBookmark(SavedTripPreview preview) {
    final next = List<SavedTripPreview>.from(value);
    final hasSourceId = preview.sourceId.trim().isNotEmpty;

    next.removeWhere((item) {
      if (item.bookmarkType != preview.bookmarkType) {
        return false;
      }

      if (hasSourceId && item.sourceId.trim().isNotEmpty) {
        return item.sourceId == preview.sourceId;
      }

      return item.destinationTitle == preview.destinationTitle;
    });
    next.insert(0, preview);

    final snapshot = List<SavedTripPreview>.unmodifiable(next);
    value = snapshot;
    unawaited(_bookmarksData.writeAll(snapshot));
  }

  void stageTrip(SavedTripPreview preview) {
    stageBookmark(preview);
  }
}
