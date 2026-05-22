import 'package:flutter/material.dart';

// Personalized file imports
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_assets.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/features/navigation/navigation_controller.dart';
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

  static final List<({String asset, String label})> _mockRecent =
      List.generate(
    AppAssets.mockRecentAssets.length,
    (index) => (
      asset: AppAssets.mockRecentAssets[index],
      label: AppStrings.mockRecentLabels[index],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.all(sizes.padL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TravelSearchBar(
                      readOnly: true,
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        final targetIndex = NavigationScope.indexOfLabel(
                          context,
                          AppStrings.navSearchLabel,
                        );
                        final controller =
                            NavigationScope.maybeControllerOf(context);

                        if (controller != null && targetIndex != null) {
                          controller.index = targetIndex;
                          controller.requestFocus();
                        }
                      },
                    ),
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
                    SliderSection(
                      title: AppStrings.viewedRecentlyTitle,
                      child: SizedBox(
                        height: sizes.sliderTileSize,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _mockRecent.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(width: sizes.sliderTileSpacing),
                          itemBuilder: (context, index) {
                            final item = _mockRecent[index];

                            return SquareImageButton(
                              imageAsset: item.asset,
                              label: item.label,
                              borderRadius: sizes.radiusL,
                              onTap: () =>
                                  debugPrint('Viewed recent ${index + 1}'),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}