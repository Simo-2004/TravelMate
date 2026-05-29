class PersonalProfile {
  static const PersonalProfile defaultProfile = PersonalProfile(
    firstName: 'Alessia',
    lastName: 'Rossi',
    description:
        'Slow traveler, beach lover, and fan of easy weekend routes. Always looking for friendly travel vibes and meaningful local experiences.',
    photoAsset: 'assets/icons/mate_avatar_1.svg',
  );

  final String firstName;
  final String lastName;
  final String description;
  final String photoAsset;

  const PersonalProfile({
    required this.firstName,
    required this.lastName,
    required this.description,
    required this.photoAsset,
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
  }) {
    return PersonalProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      description: description ?? this.description,
      photoAsset: photoAsset ?? this.photoAsset,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'description': description,
      'photoAsset': photoAsset,
    };
  }

  factory PersonalProfile.fromJson(Map<String, dynamic> json) {
    final fallback = defaultProfile;
    return PersonalProfile(
      firstName: _asString(json['firstName'], fallback.firstName),
      lastName: _asString(json['lastName'], fallback.lastName),
      description: _asString(json['description'], fallback.description),
      photoAsset: _asString(json['photoAsset'], fallback.photoAsset),
    );
  }

  static String _asString(Object? value, String fallback) {
    final parsed = value is String ? value.trim() : '';
    return parsed.isEmpty ? fallback : parsed;
  }
}
