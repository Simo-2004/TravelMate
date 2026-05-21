import 'package:flutter/material.dart';

// Personalized file imports
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
import 'package:travelmate/shared/widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(sizes.padL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.homeHeadline,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLg(sizes),
            ),
            SizedBox(height: sizes.spaceS),
            Text(
              AppStrings.homeSubtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd(sizes),
            ),
            SizedBox(height: sizes.spaceL),

            // CustomButton call
            CustomButton(
              text: AppStrings.homeCta,
              onPressed: () {
                debugPrint(AppStrings.homeCtaLog);
              },
            ),
          ],
        ),
      ),
    );
  }
}