import 'package:flutter/material.dart';

// Personalized file imports
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_assets.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/features/navigation/navigation_controller.dart';
import 'package:travelmate/features/schedule/travel_schedule_screen.dart';
import 'package:travelmate/shared/widgets/search_bar.dart';
import 'package:travelmate/shared/widgets/slider_section.dart';
import 'package:travelmate/shared/widgets/square_image_button.dart';

typedef TripTile = ({
  String asset,
  String label,
  List<String> scheduleImages,
});

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<TripTile> _tripTiles = [
    (
      asset: AppAssets.homeTrip1,
      label: AppStrings.mockTripLabels[0],
      scheduleImages: AppAssets.scheduleSet1,
    ),
    (
      asset: AppAssets.homeTrip2,
      label: AppStrings.mockTripLabels[1],
      scheduleImages: AppAssets.scheduleSet2,
    ),
    (
      asset: AppAssets.homeTrip3,
      label: AppStrings.mockTripLabels[2],
      scheduleImages: AppAssets.scheduleSet3,
    ),
    (
      asset: AppAssets.homeTrip4,
      label: AppStrings.mockTripLabels[3],
      scheduleImages: AppAssets.scheduleSet4,
    ),
    (
      asset: AppAssets.homeTrip5,
      label: AppStrings.mockTripLabels[4],
      scheduleImages: AppAssets.scheduleSet5,
    ),
    (
      asset: AppAssets.homeTrip6,
      label: AppStrings.mockTripLabels[5],
      scheduleImages: AppAssets.scheduleSet6,
    ),
  ];

  static final List<TripTile> _recentTiles = [
    _tripTiles[5],
    _tripTiles[4],
    _tripTiles[3],
    _tripTiles[2],
    _tripTiles[1],
    _tripTiles[0],
  ];

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
                          itemCount: _tripTiles.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(width: sizes.sliderTileSpacing),
                          itemBuilder: (context, index) {
                            final item = _tripTiles[index];

                            return SquareImageButton(
                              imageAsset: item.asset,
                              label: item.label,
                              borderRadius: sizes.radiusL,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TravelScheduleScreen(
                                      tripName: item.label,
                                      images: item.scheduleImages,
                                    ),
                                  ),
                                );
                              },
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
                          itemCount: _recentTiles.length,
                          separatorBuilder: (_, __) =>
                              SizedBox(width: sizes.sliderTileSpacing),
                          itemBuilder: (context, index) {
                            final item = _recentTiles[index];

                            return SquareImageButton(
                              imageAsset: item.asset,
                              label: item.label,
                              borderRadius: sizes.radiusL,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TravelScheduleScreen(
                                      tripName: item.label,
                                      images: item.scheduleImages,
                                    ),
                                  ),
                                );
                              },
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