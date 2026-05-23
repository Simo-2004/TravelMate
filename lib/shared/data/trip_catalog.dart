import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/shared/data/trip_media_catalog.dart';
import 'package:travelmate/shared/models/trip_tag.dart';
import 'package:travelmate/shared/models/trip_tile_data.dart';

class TripCatalog {
  static const List<TripTag> _tagSet1 = [
    TripTag(
      label: 'economic-trip',
      backgroundColor: Color(0xFFFFF3E0),
      textColor: Color(0xFF5D4037),
      borderColor: Color(0xFFE0BFA8),
    ),
    TripTag(
      label: 'long-journey',
      backgroundColor: Color(0xFFE3F2FD),
      textColor: Color(0xFF1E3A5F),
      borderColor: Color(0xFFB3D2F5),
    ),
    TripTag(
      label: 'family-friendly',
      backgroundColor: Color(0xFFE8F5E9),
      textColor: Color(0xFF1B5E20),
      borderColor: Color(0xFFBDE5C0),
    ),
  ];

  static const List<TripTag> _tagSet2 = [
    TripTag(
      label: 'backpacking',
      backgroundColor: Color(0xFFFFF8E1),
      textColor: Color(0xFF5F4B00),
      borderColor: Color(0xFFEAD19C),
    ),
    TripTag(
      label: 'flexible-dates',
      backgroundColor: Color(0xFFE0F7FA),
      textColor: Color(0xFF004D40),
      borderColor: Color(0xFFA7E1E6),
    ),
    TripTag(
      label: 'low-budget',
      backgroundColor: Color(0xFFE0F2F1),
      textColor: Color(0xFF004D40),
      borderColor: Color(0xFFA7D7CF),
    ),
  ];

  static const List<TripTag> _tagSet3 = [
    TripTag(
      label: 'city-break',
      backgroundColor: Color(0xFFFFEDE0),
      textColor: Color(0xFF6D3D1A),
      borderColor: Color(0xFFF5C4A2),
    ),
    TripTag(
      label: 'culture',
      backgroundColor: Color(0xFFFBE9E7),
      textColor: Color(0xFF6D3D1A),
      borderColor: Color(0xFFF5C4A2),
    ),
    TripTag(
      label: 'foodie',
      backgroundColor: Color(0xFFFFF8E1),
      textColor: Color(0xFF7A5A12),
      borderColor: Color(0xFFEAD19C),
    ),
  ];

  static const List<TripTag> _tagSet4 = [
    TripTag(
      label: 'adventure',
      backgroundColor: Color(0xFFE8F5E9),
      textColor: Color(0xFF1B5E20),
      borderColor: Color(0xFFBDE5C0),
    ),
    TripTag(
      label: 'nature',
      backgroundColor: Color(0xFFE0F7FA),
      textColor: Color(0xFF004D40),
      borderColor: Color(0xFFA7E1E6),
    ),
    TripTag(
      label: 'outdoor',
      backgroundColor: Color(0xFFE3F2FD),
      textColor: Color(0xFF1E3A5F),
      borderColor: Color(0xFFB3D2F5),
    ),
  ];

  static const List<TripTag> _tagSet5 = [
    TripTag(
      label: 'weekend',
      backgroundColor: Color(0xFFFFF3E0),
      textColor: Color(0xFF5D4037),
      borderColor: Color(0xFFE0BFA8),
    ),
    TripTag(
      label: 'romantic',
      backgroundColor: Color(0xFFFCE4EC),
      textColor: Color(0xFF880E4F),
      borderColor: Color(0xFFF5B1C8),
    ),
    TripTag(
      label: 'easy-planning',
      backgroundColor: Color(0xFFE3F2FD),
      textColor: Color(0xFF1E3A5F),
      borderColor: Color(0xFFB3D2F5),
    ),
  ];

  static const List<TripTag> _tagSet6 = [
    TripTag(
      label: 'road-trip',
      backgroundColor: Color(0xFFE8F5E9),
      textColor: Color(0xFF1B5E20),
      borderColor: Color(0xFFBDE5C0),
    ),
    TripTag(
      label: 'scenic',
      backgroundColor: Color(0xFFE3F2FD),
      textColor: Color(0xFF1E3A5F),
      borderColor: Color(0xFFB3D2F5),
    ),
    TripTag(
      label: 'group-friendly',
      backgroundColor: Color(0xFFFFF3E0),
      textColor: Color(0xFF5D4037),
      borderColor: Color(0xFFE0BFA8),
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

  static List<TripTileData> _buildTiles(List<String> labels) {
    return List.generate(_tileAssets.length, (index) {
      return TripTileData(
        asset: _tileAssets[index],
        label: labels[index],
        scheduleImages: TripMediaCatalog.scheduleSets[index],
        tags: _tagSets[index],
      );
    });
  }

  static final List<TripTileData> trips =
      _buildTiles(AppStrings.mockTripLabels);
  static final List<TripTileData> recents =
      _buildTiles(AppStrings.mockRecentLabels);
}
