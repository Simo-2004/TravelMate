import 'package:flutter/foundation.dart';

import 'package:travelmate/shared/models/saved_trip_preview.dart';

class SavedTripPreviewStore extends ValueNotifier<List<SavedTripPreview>> {
  SavedTripPreviewStore._() : super(const []);

  static final SavedTripPreviewStore instance =
      SavedTripPreviewStore._();

  void stageTrip(SavedTripPreview preview) {
    final next = List<SavedTripPreview>.from(value);

    next.removeWhere(
      (item) => item.destinationTitle == preview.destinationTitle,
    );
    next.insert(0, preview);

    value = List.unmodifiable(next);
  }
}
