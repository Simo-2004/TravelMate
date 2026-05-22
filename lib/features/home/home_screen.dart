import 'package:flutter/material.dart';

// Personalized file imports
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_assets.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/shared/widgets/search_bar.dart';
import 'package:travelmate/shared/widgets/slider_section.dart';
import 'package:travelmate/shared/widgets/square_image_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<({String asset, String label})> _mockTrips =
      List.generate(
    AppAssets.mockTripAssets.length,
    (index) => (
      asset: AppAssets.mockTripAssets[index],
      label: AppStrings.mockTripLabels[index],
    ),
  );

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
            SliderSection(
              title: AppStrings.homeSliderTitle,
              child: SizedBox(
                height: sizes.sliderTileSize,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _mockTrips.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(width: sizes.sliderTileSpacing),
                  itemBuilder: (context, index) {
                    final item = _mockTrips[index];

                    return SquareImageButton(
                      imageAsset: item.asset,
                      label: item.label,
                      borderRadius: sizes.radiusL,
                      onTap: () =>
                          debugPrint('Selected trip ${index + 1}'),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}