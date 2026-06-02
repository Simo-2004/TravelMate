import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:travelmate/shared/data/personal_profile_data.dart';
import 'package:travelmate/shared/models/personal_profile.dart';

class PersonalProfileStore extends ValueNotifier<PersonalProfile> {
  PersonalProfileStore._({PersonalProfileData? profileData})
    : _profileData = profileData ?? const PersonalProfileData(),
      super(PersonalProfile.defaultProfile);

  final PersonalProfileData _profileData;
  bool _initialized = false;

  static final PersonalProfileStore instance = PersonalProfileStore._();

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
    value = await _profileData.read();
  }

  void updateProfile(PersonalProfile profile) {
    value = profile;
    unawaited(_profileData.write(profile));
  }

  void updateDescription(String description) {
    updateProfile(value.copyWith(description: description));
  }

  void updatePhotoAsset(String photoAsset) {
    updateProfile(value.copyWith(photoAsset: photoAsset));
  }

  void updateName({String? firstName, String? lastName}) {
    updateProfile(value.copyWith(firstName: firstName, lastName: lastName));
  }
}
