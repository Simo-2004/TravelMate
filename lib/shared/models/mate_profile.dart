class MateProfile {
  final String id;
  final String name;
  final String description;
  final String? profileImageAsset;
  final List<String> keywords;
  final List<String> interests;
  final List<String> preferredTrips;

  const MateProfile({
    required this.id,
    required this.name,
    required this.description,
    this.profileImageAsset,
    this.keywords = const [],
    this.interests = const [],
    this.preferredTrips = const [],
  });
}
