import 'package:travelmate/shared/models/mate_profile.dart';

class MateCatalog {
  static const List<MateProfile> mates = [
    MateProfile(
      id: 'mate_1',
      name: 'Alessia',
      description: 'Beach lover, flexible dates, and low-budget weekend plans.',
      profileImageAsset: 'assets/icons/mate_avatar_1.svg',
      interests: [
        'low-budget',
        'group trips',
      ],
      // Matches real trip tags from TripTagCatalog (see trip_tag_catalog.dart)
      // so this mate's preferred-trip chips share styling with actual trips.
      preferredTrips: [
        'island-vibe',
        'flexible-dates',
        'weekend',
      ],
      keywords: [
        'beach',
        'weekend',
        'budget',
        'island',
      ],
    ),
    MateProfile(
      id: 'mate_2',
      name: 'Marco',
      description: 'Road trip fan, sunrise hikes, and nature photography routes.',
      profileImageAsset: 'assets/icons/mate_avatar_2.svg',
      interests: [
        'high budget',
        'adventure',
      ],
      // Matches real trip tags from TripTagCatalog (see trip_tag_catalog.dart)
      // so this mate's preferred-trip chips share styling with actual trips.
      preferredTrips: [
        'road-trip',
        'scenic',
        'nature',
      ],
      keywords: [
        'road trip',
        'nature',
        'hiking',
        'photo',
      ],
    ),
    MateProfile(
      id: 'mate_3',
      name: 'Sofia',
      description: 'City breaks, museum days, and local food exploration.',
      profileImageAsset: 'assets/icons/mate_avatar_3.svg',
      interests: [
        'high budget',
        'culture',
      ],
      // Matches real trip tags from TripTagCatalog (see trip_tag_catalog.dart)
      // so this mate's preferred-trip chips share styling with actual trips.
      preferredTrips: [
        'city-break',
        'museum-pass',
        'foodie',
      ],
      keywords: [
        'city',
        'culture',
        'museum',
        'food',
      ],
    ),
  ];
}
