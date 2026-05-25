import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
import 'package:travelmate/shared/models/mate_profile.dart';
import 'package:travelmate/shared/widgets/mate_details_panel.dart';
import 'package:travelmate/shared/widgets/mate_tag_group.dart';

class MateDetailsScreen extends StatelessWidget {
  final MateProfile mate;

  const MateDetailsScreen({
    super.key,
    required this.mate,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          AppStrings.mateDetailsPageTitle,
          style: AppTextStyles.titleLg(sizes).copyWith(
            color: AppColors.yellow,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              sizes.padL,
              sizes.padL,
              sizes.padL,
              sizes.padL * 1.4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: sizes.padS),
                MateDetailsPanel(
                  name: mate.name,
                  description: mate.description,
                  profileImageAsset: mate.profileImageAsset,
                ),
                MateTagGroup(
                  title: AppStrings.mateInterestsTitle,
                  tags: mate.interests,
                  paletteOffset: 0,
                ),
                MateTagGroup(
                  title: AppStrings.matePreferredTripsTitle,
                  tags: mate.preferredTrips,
                  paletteOffset: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
