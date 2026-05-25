import 'package:travelmate/shared/models/mate_profile.dart';

class MateCatalog {
  static const List<MateProfile> mates = [
    MateProfile(
      id: 'mate_1',
      name: 'Alessia',
      description: 'Beach lover, flexible dates, and low-budget weekend plans.',
      profileImageAsset: 'assets/icons/mate_avatar_1.svg',
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
      keywords: [
        'city',
        'culture',
        'museum',
        'food',
      ],
    ),
  ];
}
