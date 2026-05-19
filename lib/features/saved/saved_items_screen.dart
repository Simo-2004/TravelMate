import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_strings.dart';

class SavedItemsScreen extends StatelessWidget {
  const SavedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Text(
        AppStrings.pageSavedTitle,
        style: textTheme.titleLarge,
      ),
    );
  }
}
