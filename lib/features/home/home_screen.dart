import 'package:flutter/material.dart';

// Personalized file imports
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
import 'package:travelmate/shared/widgets/search_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(sizes.padL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TravelSearchBar(),
          ],
        ),
      ),
    );
  }
}