import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:travelmate/shared/models/privacy_settings.dart';

class PrivacySettingsData {
  static const String _storageKey = 'privacy_settings_v1';

  const PrivacySettingsData();

  Future<PrivacySettings> read() async {
    final preferences = await SharedPreferences.getInstance();
    final serialized = preferences.getString(_storageKey);

    if (serialized == null || serialized.isEmpty) {
      return PrivacySettings.defaults;
    }

    try {
      final decoded = jsonDecode(serialized);
      if (decoded is! Map) {
        return PrivacySettings.defaults;
      }

      return PrivacySettings.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return PrivacySettings.defaults;
    }
  }

  Future<void> write(PrivacySettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    final serialized = jsonEncode(settings.toJson());
    await preferences.setString(_storageKey, serialized);
  }
}
