import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/shared/data/trip_media_catalog.dart';
import 'package:travelmate/shared/data/trip_tag_catalog.dart';
import 'package:travelmate/shared/models/trip_tag.dart';
import 'package:travelmate/shared/models/trip_tile_data.dart';

class TripCatalog {
  static const List<TripTag> _tagSet1 = [
    TripTagCatalog.economicTrip,
    TripTagCatalog.longJourney,
    TripTagCatalog.familyFriendly,
  ];

  static const List<TripTag> _tagSet2 = [
    TripTagCatalog.backpacking,
    TripTagCatalog.flexibleDates,
    TripTagCatalog.lowBudget,
  ];

  static const List<TripTag> _tagSet3 = [
    TripTagCatalog.cityBreak,
    TripTagCatalog.culture,
    TripTagCatalog.foodie,
  ];

  static const List<TripTag> _tagSet4 = [
    TripTagCatalog.adventure,
    TripTagCatalog.nature,
    TripTagCatalog.outdoor,
  ];

  static const List<TripTag> _tagSet5 = [
    TripTagCatalog.weekend,
    TripTagCatalog.romantic,
    TripTagCatalog.easyPlanning,
  ];

  static const List<TripTag> _tagSet6 = [
    TripTagCatalog.roadTrip,
    TripTagCatalog.scenic,
    TripTagCatalog.groupFriendly,
  ];

  static const List<TripTag> _tagSet7 = [
    TripTagCatalog.islandVibe,
    TripTagCatalog.sunsetViews,
    TripTagCatalog.relaxMode,
  ];

  static const List<TripTag> _tagSet8 = [
    TripTagCatalog.historicRoute,
    TripTagCatalog.museumPass,
    TripTagCatalog.trainFriendly,
  ];

  static final List<String> _tileAssets = [...TripMediaCatalog.homeTripAssets];

  static final List<List<TripTag>> _tagSets = [
    _tagSet1,
    _tagSet2,
    _tagSet3,
    _tagSet4,
    _tagSet5,
    _tagSet6,
    _tagSet7,
    _tagSet8,
  ];

  static const List<String> _tripIds = [
    'trip_1',
    'trip_2',
    'trip_3',
    'trip_4',
    'trip_5',
    'trip_6',
    'trip_7',
    'trip_8',
  ];

  static const List<String> _destinationTitles = [...AppStrings.mockTripLabels];

  static const List<String> _tripDescriptions = [
    'A compact and budget-friendly route with easy transfers and flexible daily plans.',
    'A longer cross-region trip designed for slow travel with comfortable overnight breaks.',
    'An urban itinerary focused on landmarks, local food spots, and evening walking tours.',
    'A nature-forward schedule with scenic stops, short hikes, and open-air activities.',
    'A quick weekend escape with optimized timing for low-stress planning and transit.',
    'A road-based journey with panoramic viewpoints and group-friendly rest stops.',
    'A coastal itinerary packed with sunset viewpoints, beach transfers, and easy island hops.',
    'A heritage-focused plan with old-town walks, museum circuits, and efficient rail links.',
  ];

  static List<TripTileData> _buildTiles(List<String> labels) {
    return List.generate(_tileAssets.length, (index) {
      return TripTileData(
        tripId: _tripIds[index],
        asset: _tileAssets[index],
        label: labels[index],
        scheduleImages: TripMediaCatalog.scheduleSets[index],
        tags: _tagSets[index],
        destinationTitle: _destinationTitles[index],
        description: _tripDescriptions[index],
      );
    });
  }

  static final List<TripTileData> trips = _buildTiles(
    AppStrings.mockTripLabels,
  );
  static final List<TripTileData> recents = _buildTiles(
    AppStrings.mockRecentLabels,
  );

  static final Map<String, TripTileData> _tripById = {
    for (final trip in trips) trip.tripId: trip,
  };

  static TripTileData? findTripById(String tripId) {
    final normalizedTripId = tripId.trim().toLowerCase();
    if (normalizedTripId.isEmpty) {
      return null;
    }

    return _tripById[normalizedTripId];
  }
}
