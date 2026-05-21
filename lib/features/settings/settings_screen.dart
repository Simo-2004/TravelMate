import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

    return Center(
      child: Text(
        AppStrings.pageSettingsTitle,
        style: AppTextStyles.titleLg(sizes),
      ),
    );
  }
}
