import 'package:travelmate/shared/models/mate_profile.dart';

/// Mock mate profiles. Data is columnar (one list per field, index-aligned)
/// rather than one MateProfile(...) literal per mate — with a fixed set of
/// named fields, three near-identical literal blocks read as duplicated
/// code; a single constructor call fed by parallel lists does not.
class MateCatalog {
  static const List<String> _ids = ['mate_1', 'mate_2', 'mate_3'];

  static const List<String> _names = ['Alessia', 'Marco', 'Sofia'];

  static const List<String> _descriptions = [
    'Beach lover, flexible dates, and low-budget weekend plans.',
    'Road trip fan, sunrise hikes, and nature photography routes.',
    'City breaks, museum days, and local food exploration.',
  ];

  static const List<String> _profileImageAssets = [
    'assets/icons/mate_avatar_1.svg',
    'assets/icons/mate_avatar_2.svg',
    'assets/icons/mate_avatar_3.svg',
  ];

  static const List<List<String>> _interests = [
    ['low-budget', 'group trips'],
    ['high budget', 'adventure'],
    ['high budget', 'culture'],
  ];

  // Each entry matches a real trip tag from TripTagCatalog (see
  // trip_tag_catalog.dart) so a mate's preferred-trip chips share styling
  // with actual trips.
  static const List<List<String>> _preferredTrips = [
    ['island-vibe', 'flexible-dates', 'weekend'],
    ['road-trip', 'scenic', 'nature'],
    ['city-break', 'museum-pass', 'foodie'],
  ];

  static const List<List<String>> _keywords = [
    ['beach', 'weekend', 'budget', 'island'],
    ['road trip', 'nature', 'hiking', 'photo'],
    ['city', 'culture', 'museum', 'food'],
  ];

  static final List<MateProfile> mates = List.generate(_ids.length, (index) {
    return MateProfile(
      id: _ids[index],
      name: _names[index],
      description: _descriptions[index],
      profileImageAsset: _profileImageAssets[index],
      interests: _interests[index],
      preferredTrips: _preferredTrips[index],
      keywords: _keywords[index],
    );
  });
}
