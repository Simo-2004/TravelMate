import 'package:travelmate/shared/models/mate_profile.dart';
import 'package:travelmate/shared/models/trip_tile_data.dart';

/// True when at least one of [trip]'s tags appears among [mate]'s own tags
/// (interests + preferred trips), meaning the mate would accept an invite
/// to that trip; otherwise they politely decline.
bool mateLikesTrip(MateProfile mate, TripTileData trip) {
  final mateTags = <String>{
    for (final tag in [...mate.interests, ...mate.preferredTrips])
      tag.trim().toLowerCase(),
  };

  return trip.tags.any(
    (tag) => mateTags.contains(tag.label.trim().toLowerCase()),
  );
}
