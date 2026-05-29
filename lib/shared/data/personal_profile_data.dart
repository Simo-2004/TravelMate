import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelmate/shared/models/personal_profile.dart';

class PersonalProfileData {
  static const String _storageKey = 'personal_profile_v1';

  const PersonalProfileData();

  Future<PersonalProfile> read() async {
    final preferences = await SharedPreferences.getInstance();
    final serialized = preferences.getString(_storageKey);

    if (serialized == null || serialized.isEmpty) {
      return PersonalProfile.defaultProfile;
    }

    try {
      final decoded = jsonDecode(serialized);
      if (decoded is! Map) {
        return PersonalProfile.defaultProfile;
      }

      return PersonalProfile.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return PersonalProfile.defaultProfile;
    }
  }

  Future<void> write(PersonalProfile profile) async {
    final preferences = await SharedPreferences.getInstance();
    final serialized = jsonEncode(profile.toJson());
    await preferences.setString(_storageKey, serialized);
  }
}
