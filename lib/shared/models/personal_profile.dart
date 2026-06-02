class PersonalProfile {
  static const PersonalProfile defaultProfile = PersonalProfile(
    firstName: 'Alessia',
    lastName: 'Rossi',
    description:
        'Slow traveler, beach lover, and fan of easy weekend routes. Always looking for friendly travel vibes and meaningful local experiences.',
    photoAsset: 'assets/icons/mate_avatar_1.svg',
    interestTags: <String>['Beach life', 'Food tours', 'City walks'],
    tripTags: <String>['Weekend escapes', 'Road trips', 'Island hopping'],
  );

  final String firstName;
  final String lastName;
  final String description;
  final String photoAsset;
  final List<String> interestTags;
  final List<String> tripTags;

  const PersonalProfile({
    required this.firstName,
    required this.lastName,
    required this.description,
    required this.photoAsset,
    this.interestTags = const <String>[],
    this.tripTags = const <String>[],
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? 'Traveler profile' : name;
  }

  PersonalProfile copyWith({
    String? firstName,
    String? lastName,
    String? description,
    String? photoAsset,
    List<String>? interestTags,
    List<String>? tripTags,
  }) {
    return PersonalProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      description: description ?? this.description,
      photoAsset: photoAsset ?? this.photoAsset,
      interestTags: List<String>.from(interestTags ?? this.interestTags),
      tripTags: List<String>.from(tripTags ?? this.tripTags),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'description': description,
      'photoAsset': photoAsset,
      'interestTags': interestTags,
      'tripTags': tripTags,
    };
  }

  factory PersonalProfile.fromJson(Map<String, dynamic> json) {
    final fallback = defaultProfile;
    return PersonalProfile(
      firstName: _asString(json['firstName'], fallback.firstName),
      lastName: _asString(json['lastName'], fallback.lastName),
      description: _asString(json['description'], fallback.description),
      photoAsset: _asString(json['photoAsset'], fallback.photoAsset),
      interestTags: _asStringList(json['interestTags'], fallback.interestTags),
      tripTags: _asStringList(json['tripTags'], fallback.tripTags),
    );
  }

  static String _asString(Object? value, String fallback) {
    final parsed = value is String ? value.trim() : '';
    return parsed.isEmpty ? fallback : parsed;
  }

  static List<String> _asStringList(Object? value, List<String> fallback) {
    if (value == null) {
      return List<String>.from(fallback);
    }

    if (value is! List) {
      return List<String>.from(fallback);
    }

    return value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }
}
