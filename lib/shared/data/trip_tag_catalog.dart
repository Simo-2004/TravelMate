import 'package:flutter/material.dart';

import 'package:travelmate/shared/models/trip_tag.dart';

/// Canonical set of trip tags (label + colors), shared by [TripCatalog] and
/// any other feature that needs to reference a *real* trip tag rather than
/// an arbitrary label — e.g. a mate's preferred-trip tags, so they can be
/// styled to match the actual trip tag they refer to.
class TripTagCatalog {
  static const TripTag economicTrip = TripTag(
    label: 'economic-trip',
    backgroundColor: Color(0xFFFFF700),
    textColor: Color(0xFF3A3200),
    borderColor: Color(0xFFFFF199),
  );
  static const TripTag longJourney = TripTag(
    label: 'long-journey',
    backgroundColor: Color(0xFF00E5FF),
    textColor: Color(0xFF00343A),
    borderColor: Color(0xFF99F8FF),
  );
  static const TripTag familyFriendly = TripTag(
    label: 'family-friendly',
    backgroundColor: Color(0xFF7CFF4D),
    textColor: Color(0xFF1F3A00),
    borderColor: Color(0xFFC8FFB5),
  );
  static const TripTag backpacking = TripTag(
    label: 'backpacking',
    backgroundColor: Color(0xFFFF9100),
    textColor: Color(0xFF4A2600),
    borderColor: Color(0xFFFFD299),
  );
  static const TripTag flexibleDates = TripTag(
    label: 'flexible-dates',
    backgroundColor: Color(0xFFFF4FD8),
    textColor: Color(0xFF3A0032),
    borderColor: Color(0xFFFFC2EF),
  );
  static const TripTag lowBudget = TripTag(
    label: 'low-budget',
    backgroundColor: Color(0xFFB24CFF),
    textColor: Color(0xFF2F005C),
    borderColor: Color(0xFFE0B6FF),
  );
  static const TripTag cityBreak = TripTag(
    label: 'city-break',
    backgroundColor: Color(0xFF00F0FF),
    textColor: Color(0xFF00343A),
    borderColor: Color(0xFF99F8FF),
  );
  static const TripTag culture = TripTag(
    label: 'culture',
    backgroundColor: Color(0xFFFF4FD8),
    textColor: Color(0xFF3A0032),
    borderColor: Color(0xFFFFC2EF),
  );
  static const TripTag foodie = TripTag(
    label: 'foodie',
    backgroundColor: Color(0xFFFFF700),
    textColor: Color(0xFF3A3200),
    borderColor: Color(0xFFFFF199),
  );
  static const TripTag adventure = TripTag(
    label: 'adventure',
    backgroundColor: Color(0xFF7CFF4D),
    textColor: Color(0xFF1F3A00),
    borderColor: Color(0xFFC8FFB5),
  );
  static const TripTag nature = TripTag(
    label: 'nature',
    backgroundColor: Color(0xFF00E5FF),
    textColor: Color(0xFF00343A),
    borderColor: Color(0xFF99F8FF),
  );
  static const TripTag outdoor = TripTag(
    label: 'outdoor',
    backgroundColor: Color(0xFFFF9100),
    textColor: Color(0xFF4A2600),
    borderColor: Color(0xFFFFD299),
  );
  static const TripTag weekend = TripTag(
    label: 'weekend',
    backgroundColor: Color(0xFFFFF700),
    textColor: Color(0xFF3A3200),
    borderColor: Color(0xFFFFF199),
  );
  static const TripTag romantic = TripTag(
    label: 'romantic',
    backgroundColor: Color(0xFFFF4FD8),
    textColor: Color(0xFF3A0032),
    borderColor: Color(0xFFFFC2EF),
  );
  static const TripTag easyPlanning = TripTag(
    label: 'easy-planning',
    backgroundColor: Color(0xFFB24CFF),
    textColor: Color(0xFF2F005C),
    borderColor: Color(0xFFE0B6FF),
  );
  static const TripTag roadTrip = TripTag(
    label: 'road-trip',
    backgroundColor: Color(0xFFFF9100),
    textColor: Color(0xFF4A2600),
    borderColor: Color(0xFFFFD299),
  );
  static const TripTag scenic = TripTag(
    label: 'scenic',
    backgroundColor: Color(0xFF00E5FF),
    textColor: Color(0xFF00343A),
    borderColor: Color(0xFF99F8FF),
  );
  static const TripTag groupFriendly = TripTag(
    label: 'group-friendly',
    backgroundColor: Color(0xFF7CFF4D),
    textColor: Color(0xFF1F3A00),
    borderColor: Color(0xFFC8FFB5),
  );
  static const TripTag islandVibe = TripTag(
    label: 'island-vibe',
    backgroundColor: Color(0xFF00F5A0),
    textColor: Color(0xFF00422A),
    borderColor: Color(0xFF8DFFD2),
  );
  static const TripTag sunsetViews = TripTag(
    label: 'sunset-views',
    backgroundColor: Color(0xFFFF8A00),
    textColor: Color(0xFF4A2600),
    borderColor: Color(0xFFFFD3A1),
  );
  static const TripTag relaxMode = TripTag(
    label: 'relax-mode',
    backgroundColor: Color(0xFF00E5FF),
    textColor: Color(0xFF00343A),
    borderColor: Color(0xFF99F8FF),
  );
  static const TripTag historicRoute = TripTag(
    label: 'historic-route',
    backgroundColor: Color(0xFFFF5C8A),
    textColor: Color(0xFF4A0018),
    borderColor: Color(0xFFFFBDD0),
  );
  static const TripTag museumPass = TripTag(
    label: 'museum-pass',
    backgroundColor: Color(0xFFB24CFF),
    textColor: Color(0xFF2F005C),
    borderColor: Color(0xFFE0B6FF),
  );
  static const TripTag trainFriendly = TripTag(
    label: 'train-friendly',
    backgroundColor: Color(0xFFFFF700),
    textColor: Color(0xFF3A3200),
    borderColor: Color(0xFFFFF199),
  );

  static const List<TripTag> all = [
    economicTrip,
    longJourney,
    familyFriendly,
    backpacking,
    flexibleDates,
    lowBudget,
    cityBreak,
    culture,
    foodie,
    adventure,
    nature,
    outdoor,
    weekend,
    romantic,
    easyPlanning,
    roadTrip,
    scenic,
    groupFriendly,
    islandVibe,
    sunsetViews,
    relaxMode,
    historicRoute,
    museumPass,
    trainFriendly,
  ];

  static final Map<String, TripTag> _byLabel = {
    for (final tag in all) _normalize(tag.label): tag,
  };

  /// Looks up the canonical [TripTag] for [label], or null if [label]
  /// doesn't match any known trip tag.
  static TripTag? resolve(String label) => _byLabel[_normalize(label)];

  static String _normalize(String label) => label.trim().toLowerCase();
}
