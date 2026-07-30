import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:travelmate/shared/data/profile_data_source.dart';
import 'package:travelmate/shared/data/sqlite_profile_data.dart';
import 'package:travelmate/shared/models/personal_profile.dart';

/// Holds the current user's [PersonalProfile], persisted through an injected
/// [ProfileDataSource] (SQLite by default; see [SqliteProfileData]).
class PersonalProfileStore extends ValueNotifier<PersonalProfile> {
  PersonalProfileStore._({ProfileDataSource? profileData})
    : _profileData = profileData ?? SqliteProfileData.production(),
      super(PersonalProfile.defaultProfile);

  ProfileDataSource _profileData;
  bool _initialized = false;

  static final PersonalProfileStore instance = PersonalProfileStore._();

  /// Replaces the backing data source. Test-only seam so widget/unit tests can
  /// inject an in-memory source instead of touching SQLite / secure storage.
  @visibleForTesting
  void debugSetDataSource(ProfileDataSource source) {
    _profileData = source;
    _initialized = false;
  }

  /// Loads the persisted profile on first call; a no-op afterwards.
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
    value = await _profileData.read();
  }

  /// Replaces the current profile and persists it.
  void updateProfile(PersonalProfile profile) {
    value = profile;
    unawaited(_profileData.write(profile));
  }

  /// Updates just the description, persisting the change.
  void updateDescription(String description) {
    updateProfile(value.copyWith(description: description));
  }

  /// Updates just the photo asset/file path, persisting the change.
  void updatePhotoAsset(String photoAsset) {
    updateProfile(value.copyWith(photoAsset: photoAsset));
  }

  /// Updates the first and/or last name, persisting the change.
  void updateName({String? firstName, String? lastName}) {
    updateProfile(value.copyWith(firstName: firstName, lastName: lastName));
  }
}
