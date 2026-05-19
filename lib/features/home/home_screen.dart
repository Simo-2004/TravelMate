import 'package:flutter/material.dart';

// Personalized file imports
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/shared/widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.padL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.homeHeadline,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: AppSizes.spaceS),
            Text(
              AppStrings.homeSubtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSizes.spaceL),

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