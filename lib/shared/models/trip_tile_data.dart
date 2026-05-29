import 'package:travelmate/shared/models/trip_tag.dart';

class TripTileData {
  final String tripId;
  final String asset;
  final String label;
  final List<String> scheduleImages;
  final List<TripTag> tags;
  final String destinationTitle;
  final String description;

  const TripTileData({
    required this.tripId,
    required this.asset,
    required this.label,
    required this.scheduleImages,
    required this.tags,
    required this.destinationTitle,
    required this.description,
  });
}
