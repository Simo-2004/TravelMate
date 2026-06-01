import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/features/profile/personal_profile_screen.dart';
import 'package:travelmate/features/settings/privacy_settings_screen.dart';
import 'package:travelmate/features/settings/support_screen.dart';
import 'package:travelmate/shared/models/personal_profile.dart';
import 'package:travelmate/shared/state/personal_profile_store.dart';
import 'package:travelmate/shared/widgets/personal_profile_card.dart';
import 'package:travelmate/shared/widgets/settings_action_card.dart';
import 'package:travelmate/shared/widgets/settings_action_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _handleExit(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Exit action pressed.')));
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

    return ValueListenableBuilder<PersonalProfile>(
      valueListenable: PersonalProfileStore.instance,
      builder: (context, profile, _) {
        return SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentMaxWidth = constraints.maxWidth > 760
                  ? 560.0
                  : double.infinity;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  sizes.padL,
                  sizes.padS,
                  sizes.padL,
                  sizes.padL * 1.4,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ProfileIdentityHeader(profile: profile),
                        SizedBox(height: sizes.spaceM),
                        PersonalProfileCard(
                          profile: profile,
                          showAvatar: false,
                          showName: false,
                        ),
                        SizedBox(height: sizes.spaceM),
                        SettingsActionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SettingsActionButton(
                                label: 'Profile',
                                color: AppColors.yellow,
                                iconAsset: 'assets/icons/user_icon.svg',
                                textColor: AppColors.black,
                                iconColor: AppColors.yellow,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const PersonalProfileScreen(),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: sizes.padS),
                              SettingsActionButton(
                                label: 'Privacy',
                                color: const Color(0xFF2F80ED),
                                iconAsset: 'assets/icons/lock.svg',
                                textColor: AppColors.black,
                                iconColor: Color(0xFF2F80ED),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const PrivacySettingsScreen(),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: sizes.padS),
                              SettingsActionButton(
                                label: 'Support',
                                color: const Color(0xFF2FA84F),
                                iconAsset: 'assets/icons/handphones.svg',
                                textColor: AppColors.black,
                                iconColor: Color(0xFF2FA84F),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SupportScreen(),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: sizes.spaceS),
                              SettingsActionButton(
                                label: 'Exit',
                                color: const Color(0xFFFF5353),
                                iconAsset: 'assets/icons/exit.svg',
                                onTap: () => _handleExit(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
