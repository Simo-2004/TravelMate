import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelmate/shared/data/profile_data_source.dart';
import 'package:travelmate/shared/models/personal_profile.dart';

/// Legacy SharedPreferences-backed profile storage.
///
/// Retained after the SQLite migration so [SqliteProfileData] can import any
/// profile a previous app version saved here (see [readStored]). Still usable
/// as a [ProfileDataSource] on its own.
class PersonalProfileData implements ProfileDataSource {
  static const String _storageKey = 'personal_profile_v1';

  const PersonalProfileData();

  @override
  Future<PersonalProfile> read() async {
    return await readStored() ?? PersonalProfile.defaultProfile;
  }

  /// Returns the persisted profile, or null when nothing was ever stored.
  /// Used by the SQLite migration to distinguish "no legacy data" from
  /// "legacy data that happens to equal the default profile".
  Future<PersonalProfile?> readStored() async {
    final preferences = await SharedPreferences.getInstance();
    final serialized = preferences.getString(_storageKey);

    if (serialized == null || serialized.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(serialized);
      if (decoded is! Map) {
        return null;
      }

      return PersonalProfile.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(PersonalProfile profile) async {
    final preferences = await SharedPreferences.getInstance();
    final serialized = jsonEncode(profile.toJson());
    await preferences.setString(_storageKey, serialized);
  }
}
