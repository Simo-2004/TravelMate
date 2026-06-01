import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:travelmate/shared/data/privacy_settings_data.dart';
import 'package:travelmate/shared/models/privacy_settings.dart';

class PrivacySettingsStore extends ValueNotifier<PrivacySettings> {
  PrivacySettingsStore._({PrivacySettingsData? settingsData})
    : _settingsData = settingsData ?? const PrivacySettingsData(),
      super(PrivacySettings.defaults);

  final PrivacySettingsData _settingsData;
  bool _initialized = false;

  static final PrivacySettingsStore instance = PrivacySettingsStore._();

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
    value = await _settingsData.read();
  }

  void updateSettings(PrivacySettings settings) {
    value = settings;
    unawaited(_settingsData.write(settings));
  }

  void updateSetting(PrivacySettingKey key, bool settingValue) {
    updateSettings(value.copyWithKey(key, settingValue));
  }
}
