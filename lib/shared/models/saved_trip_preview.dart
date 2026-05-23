import 'package:travelmate/shared/models/trip_tag.dart';

class SavedTripPreview {
  final String tripName;
  final String destinationTitle;
  final String description;
  final String coverImage;
  final List<TripTag> tags;

  const SavedTripPreview({
    required this.tripName,
    required this.destinationTitle,
    required this.description,
    required this.coverImage,
    required this.tags,
  });
}
