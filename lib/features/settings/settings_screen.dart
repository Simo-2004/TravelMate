import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_strings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Text(
        AppStrings.pageSettingsTitle,
        style: textTheme.titleLarge,
      ),
    );
  }
}
