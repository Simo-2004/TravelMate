import 'package:travelmate/shared/models/personal_profile.dart';

/// Read/write contract for the persisted personal profile.
///
/// [PersonalProfileStore] depends on this abstraction, so its backing store can
/// change (SharedPreferences → SQLite) without touching the store, the UI, or
/// the model. Both [PersonalProfileData] (legacy) and [SqliteProfileData]
/// (current) implement it.
abstract class ProfileDataSource {
  /// Returns the stored profile, falling back to
  /// [PersonalProfile.defaultProfile] when nothing has been persisted yet.
  Future<PersonalProfile> read();

  Future<void> write(PersonalProfile profile);
}
