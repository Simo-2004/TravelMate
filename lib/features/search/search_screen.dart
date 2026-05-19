import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_strings.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Text(
        AppStrings.pageSearchTitle,
        style: textTheme.titleLarge,
      ),
    );
  }
}
