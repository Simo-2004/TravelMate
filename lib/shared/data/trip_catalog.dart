import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/shared/data/trip_media_catalog.dart';
import 'package:travelmate/shared/models/trip_tag.dart';
import 'package:travelmate/shared/models/trip_tile_data.dart';

class TripCatalog {
  static const List<TripTag> _tagSet1 = [
    TripTag(
      label: 'economic-trip',
      backgroundColor: Color(0xFFFFF700),
      textColor: Color(0xFF3A3200),
      borderColor: Color(0xFFFFF199),
    ),
    TripTag(
      label: 'long-journey',
      backgroundColor: Color(0xFF00E5FF),
      textColor: Color(0xFF00343A),
      borderColor: Color(0xFF99F8FF),
    ),
    TripTag(
      label: 'family-friendly',
      backgroundColor: Color(0xFF7CFF4D),
      textColor: Color(0xFF1F3A00),
      borderColor: Color(0xFFC8FFB5),
    ),
  ];

  static const List<TripTag> _tagSet2 = [
    TripTag(
      label: 'backpacking',
      backgroundColor: Color(0xFFFF9100),
      textColor: Color(0xFF4A2600),
      borderColor: Color(0xFFFFD299),
    ),
    TripTag(
      label: 'flexible-dates',
      backgroundColor: Color(0xFFFF4FD8),
      textColor: Color(0xFF3A0032),
      borderColor: Color(0xFFFFC2EF),
    ),
    TripTag(
      label: 'low-budget',
      backgroundColor: Color(0xFFB24CFF),
      textColor: Color(0xFF2F005C),
      borderColor: Color(0xFFE0B6FF),
    ),
  ];

  static const List<TripTag> _tagSet3 = [
    TripTag(
      label: 'city-break',
      backgroundColor: Color(0xFF00F0FF),
      textColor: Color(0xFF00343A),
      borderColor: Color(0xFF99F8FF),
    ),
    TripTag(
      label: 'culture',
      backgroundColor: Color(0xFFFF4FD8),
      textColor: Color(0xFF3A0032),
      borderColor: Color(0xFFFFC2EF),
    ),
    TripTag(
      label: 'foodie',
      backgroundColor: Color(0xFFFFF700),
      textColor: Color(0xFF3A3200),
      borderColor: Color(0xFFFFF199),
    ),
  ];

  static const List<TripTag> _tagSet4 = [
    TripTag(
      label: 'adventure',
      backgroundColor: Color(0xFF7CFF4D),
      textColor: Color(0xFF1F3A00),
      borderColor: Color(0xFFC8FFB5),
    ),
    TripTag(
      label: 'nature',
      backgroundColor: Color(0xFF00E5FF),
      textColor: Color(0xFF00343A),
      borderColor: Color(0xFF99F8FF),
    ),
    TripTag(
      label: 'outdoor',
      backgroundColor: Color(0xFFFF9100),
      textColor: Color(0xFF4A2600),
      borderColor: Color(0xFFFFD299),
    ),
  ];

  static const List<TripTag> _tagSet5 = [
    TripTag(
      label: 'weekend',
      backgroundColor: Color(0xFFFFF700),
      textColor: Color(0xFF3A3200),
      borderColor: Color(0xFFFFF199),
    ),
    TripTag(
      label: 'romantic',
      backgroundColor: Color(0xFFFF4FD8),
      textColor: Color(0xFF3A0032),
      borderColor: Color(0xFFFFC2EF),
    ),
    TripTag(
      label: 'easy-planning',
      backgroundColor: Color(0xFFB24CFF),
      textColor: Color(0xFF2F005C),
      borderColor: Color(0xFFE0B6FF),
    ),
  ];

  static const List<TripTag> _tagSet6 = [
    TripTag(
      label: 'road-trip',
      backgroundColor: Color(0xFFFF9100),
      textColor: Color(0xFF4A2600),
      borderColor: Color(0xFFFFD299),
    ),
    TripTag(
      label: 'scenic',
      backgroundColor: Color(0xFF00E5FF),
      textColor: Color(0xFF00343A),
      borderColor: Color(0xFF99F8FF),
    ),
    TripTag(
      label: 'group-friendly',
      backgroundColor: Color(0xFF7CFF4D),
      textColor: Color(0xFF1F3A00),
      borderColor: Color(0xFFC8FFB5),
    ),
  ];

  static final List<String> _tileAssets = [
    ...TripMediaCatalog.homeTripAssets,
  ];

  static final List<List<TripTag>> _tagSets = [
    _tagSet1,
    _tagSet2,
    _tagSet3,
    _tagSet4,
    _tagSet5,
    _tagSet6,
  ];

  static const List<String> _destinationTitles = [
    ...AppStrings.mockTripLabels,
  ];

  static const List<String> _tripDescriptions = [
    'A compact and budget-friendly route with easy transfers and flexible daily plans.',
    'A longer cross-region trip designed for slow travel with comfortable overnight breaks.',
    'An urban itinerary focused on landmarks, local food spots, and evening walking tours.',
    'A nature-forward schedule with scenic stops, short hikes, and open-air activities.',
    'A quick weekend escape with optimized timing for low-stress planning and transit.',
    'A road-based journey with panoramic viewpoints and group-friendly rest stops.',
  ];

  static List<TripTileData> _buildTiles(List<String> labels) {
    return List.generate(_tileAssets.length, (index) {
      return TripTileData(
        asset: _tileAssets[index],
        label: labels[index],
        scheduleImages: TripMediaCatalog.scheduleSets[index],
        tags: _tagSets[index],
        destinationTitle: _destinationTitles[index],
        description: _tripDescriptions[index],
      );
    });
  }

  static final List<TripTileData> trips =
      _buildTiles(AppStrings.mockTripLabels);
  static final List<TripTileData> recents =
      _buildTiles(AppStrings.mockRecentLabels);
}
