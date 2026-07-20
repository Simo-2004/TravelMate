enum PrivacySettingKey {
  privateProfile,
  onlyPeopleInRadius,
  checkMessages,
  offlineMode,
}

class PrivacySettings {
  static const PrivacySettings defaults = PrivacySettings(
    privateProfile: false,
    onlyPeopleInRadius: false,
    checkMessages: false,
    offlineMode: false,
  );

  final bool privateProfile;
  final bool onlyPeopleInRadius;
  final bool checkMessages;
  final bool offlineMode;

  const PrivacySettings({
    required this.privateProfile,
    required this.onlyPeopleInRadius,
    required this.checkMessages,
    required this.offlineMode,
  });

  PrivacySettings copyWith({
    bool? privateProfile,
    bool? onlyPeopleInRadius,
    bool? checkMessages,
    bool? offlineMode,
  }) {
    return PrivacySettings(
      privateProfile: privateProfile ?? this.privateProfile,
      onlyPeopleInRadius: onlyPeopleInRadius ?? this.onlyPeopleInRadius,
      checkMessages: checkMessages ?? this.checkMessages,
      offlineMode: offlineMode ?? this.offlineMode,
    );
  }

  bool valueFor(PrivacySettingKey key) {
    switch (key) {
      case PrivacySettingKey.privateProfile:
        return privateProfile;
      case PrivacySettingKey.onlyPeopleInRadius:
        return onlyPeopleInRadius;
      case PrivacySettingKey.checkMessages:
        return checkMessages;
      case PrivacySettingKey.offlineMode:
        return offlineMode;
    }
  }

  PrivacySettings copyWithKey(PrivacySettingKey key, bool value) {
    switch (key) {
      case PrivacySettingKey.privateProfile:
        return copyWith(privateProfile: value);
      case PrivacySettingKey.onlyPeopleInRadius:
        return copyWith(onlyPeopleInRadius: value);
      case PrivacySettingKey.checkMessages:
        return copyWith(checkMessages: value);
      case PrivacySettingKey.offlineMode:
        return copyWith(offlineMode: value);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'privateProfile': privateProfile,
      'onlyPeopleInRadius': onlyPeopleInRadius,
      'checkMessages': checkMessages,
      'offlineMode': offlineMode,
    };
  }

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    const fallback = defaults;
    return PrivacySettings(
      privateProfile: _asBool(json['privateProfile'], fallback.privateProfile),
      onlyPeopleInRadius: _asBool(
        json['onlyPeopleInRadius'],
        fallback.onlyPeopleInRadius,
      ),
      checkMessages: _asBool(json['checkMessages'], fallback.checkMessages),
      offlineMode: _asBool(json['offlineMode'], fallback.offlineMode),
    );
  }

  static bool _asBool(Object? value, bool fallback) {
    return value is bool ? value : fallback;
  }
}
