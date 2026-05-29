import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/shared/models/personal_profile.dart';
import 'package:travelmate/shared/state/personal_profile_store.dart';
import 'package:travelmate/shared/widgets/personal_profile_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
