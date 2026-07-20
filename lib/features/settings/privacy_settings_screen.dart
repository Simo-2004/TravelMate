import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
import 'package:travelmate/shared/models/privacy_settings.dart';
import 'package:travelmate/shared/state/privacy_settings_store.dart';
import 'package:travelmate/shared/widgets/settings_action_card.dart';

typedef PrivacySettingChanged =
    void Function(PrivacySettingKey key, bool value, PrivacySettings settings);

typedef PrivacySettingsChanged = void Function(PrivacySettings settings);

/// Screen exposing privacy toggles backed by persistent local settings.
class PrivacySettingsScreen extends StatefulWidget {
  final PrivacySettingChanged? onSettingChanged;
  final PrivacySettingsChanged? onSettingsChanged;

  const PrivacySettingsScreen({
    super.key,
    this.onSettingChanged,
    this.onSettingsChanged,
  });

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  static const List<_PrivacyToggleDefinition> _toggleDefinitions = [
    _PrivacyToggleDefinition(
      key: PrivacySettingKey.privateProfile,
      label: AppStrings.privacyPrivateProfileLabel,
    ),
    _PrivacyToggleDefinition(
      key: PrivacySettingKey.onlyPeopleInRadius,
      label: AppStrings.privacyRadiusOnlyLabel,
    ),
    _PrivacyToggleDefinition(
      key: PrivacySettingKey.checkMessages,
      label: AppStrings.privacyCheckMessagesLabel,
    ),
    _PrivacyToggleDefinition(
      key: PrivacySettingKey.offlineMode,
      label: AppStrings.privacyOfflineModeLabel,
    ),
  ];

  void _toggleSetting(
    BuildContext context,
    PrivacySettings settings,
    PrivacySettingKey key,
    String label,
    bool value,
  ) {
    final updated = settings.copyWithKey(key, value);

    PrivacySettingsStore.instance.updateSettings(updated);

    widget.onSettingChanged?.call(key, value, updated);
    widget.onSettingsChanged?.call(updated);

    final stateLabel = value ? 'On' : 'Off';
    final message = '$label $stateLabel';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          AppStrings.settingsPrivacyTitle,
          style: AppTextStyles.titleLg(sizes).copyWith(color: AppColors.yellow),
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<PrivacySettings>(
          valueListenable: PrivacySettingsStore.instance,
          builder: (context, settings, _) => SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              sizes.padL,
              sizes.padL,
              sizes.padL,
              sizes.padL * 1.4,
            ),
            child: SettingsActionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppStrings.privacySectionTitle,
                    style: AppTextStyles.titleLg(
                      sizes,
                    ).copyWith(fontSize: sizes.textMd),
                  ),
                  SizedBox(height: sizes.padXs),
                  Text(
                    AppStrings.privacySectionSubtitle,
                    style: AppTextStyles.bodyMd(
                      sizes,
                    ).copyWith(color: AppColors.blackAlpha60),
                  ),
                  SizedBox(height: sizes.spaceM),
                  ..._toggleDefinitions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final definition = entry.value;
                    final isLast = index == _toggleDefinitions.length - 1;

                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : sizes.padS),
                      child: _PrivacyBooleanButtonTile(
                        label: definition.label,
                        value: settings.valueFor(definition.key),
                        onChanged: (value) => _toggleSetting(
                          context,
                          settings,
                          definition.key,
                          definition.label,
                          value,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivacyBooleanButtonTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrivacyBooleanButtonTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizes.padM,
        vertical: sizes.padS * 0.92,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCED),
        borderRadius: BorderRadius.circular(sizes.radiusM),
        border: Border.all(
          color: AppColors.blackAlpha60,
          width: sizes.padXs * 0.2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMd(
                sizes,
              ).copyWith(color: AppColors.black, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(width: sizes.padS),
          Switch.adaptive(
            value: value,
            activeThumbColor: AppColors.yellow,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PrivacyToggleDefinition {
  final PrivacySettingKey key;
  final String label;

  const _PrivacyToggleDefinition({required this.key, required this.label});
}
