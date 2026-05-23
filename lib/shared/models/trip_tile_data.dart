import 'package:travelmate/shared/models/trip_tag.dart';

class TripTileData {
  final String asset;
  final String label;
  final List<String> scheduleImages;
  final List<TripTag> tags;

  const TripTileData({
    required this.asset,
    required this.label,
    required this.scheduleImages,
    required this.tags,
  });
}
