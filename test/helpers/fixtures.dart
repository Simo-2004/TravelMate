/// Builders for the app's domain objects.
///
/// Tests state only the fields they actually assert on; everything else gets a
/// deterministic default derived from the id, so failures point at the value
/// under test rather than at incidental setup.
library;

import 'package:flutter/material.dart';

import 'package:travelmate/shared/models/chat_message.dart';
import 'package:travelmate/shared/models/mate_profile.dart';
import 'package:travelmate/shared/models/saved_trip_preview.dart';
import 'package:travelmate/shared/models/trip_tag.dart';
import 'package:travelmate/shared/models/trip_tile_data.dart';

/// A tag with fixed, recognisable colors. Pass [borderColor] to exercise the
/// optional-border branch of the tag codec.
TripTag buildTag(String label, {Color? borderColor}) {
  return TripTag(
    label: label,
    backgroundColor: const Color(0xFF112233),
    textColor: const Color(0xFF445566),
    borderColor: borderColor,
  );
}

/// A trip whose asset paths and copy are all derived from [id] / [label].
TripTileData buildTrip({
  required String id,
  String label = 'Trip',
  String? destinationTitle,
  String? description,
  List<TripTag> tags = const [],
  List<String>? scheduleImages,
}) {
  return TripTileData(
    tripId: id,
    asset: 'assets/images/home/$id.svg',
    label: label,
    scheduleImages: scheduleImages ?? ['assets/images/schedule/${id}_1.svg'],
    tags: tags,
    destinationTitle: destinationTitle ?? 'Destination $label',
    description: description ?? 'Description of $label',
  );
}

/// Same as [buildTrip] but takes plain tag labels, for the many tests that
/// only care about matching text and not about tag colors.
TripTileData buildTaggedTrip({
  required String id,
  String label = 'Trip',
  String? destinationTitle,
  String? description,
  List<String> tagLabels = const [],
}) {
  return buildTrip(
    id: id,
    label: label,
    destinationTitle: destinationTitle,
    description: description,
    tags: tagLabels.map(buildTag).toList(),
  );
}

/// A mate profile with empty list fields unless specified.
MateProfile buildMate({
  required String id,
  String name = 'Mate',
  String description = '',
  String? profileImageAsset,
  List<String> keywords = const [],
  List<String> interests = const [],
  List<String> preferredTrips = const [],
}) {
  return MateProfile(
    id: id,
    name: name,
    description: description,
    profileImageAsset: profileImageAsset,
    keywords: keywords,
    interests: interests,
    preferredTrips: preferredTrips,
  );
}

/// A saved bookmark, of either [SavedBookmarkType].
SavedTripPreview buildBookmark({
  String name = 'Trip 1',
  String sourceId = 'trip_1',
  String type = SavedBookmarkType.trip,
  String destinationTitle = 'Dest',
  List<TripTag> tags = const [],
}) {
  return SavedTripPreview(
    tripName: name,
    destinationTitle: destinationTitle,
    description: 'Desc',
    coverImage: '',
    tags: tags,
    bookmarkType: type,
    sourceId: sourceId,
  );
}

/// A chat message at a fixed timestamp, so ordering assertions are stable.
ChatMessage buildMessage(
  String id, {
  String text = 'hi',
  bool isFromMe = true,
  DateTime? sentAt,
  String? attachedTripId,
}) {
  return ChatMessage(
    id: id,
    text: text,
    isFromMe: isFromMe,
    sentAt: sentAt ?? DateTime(2024, 1, 1, 10),
    attachedTripId: attachedTripId,
  );
}
