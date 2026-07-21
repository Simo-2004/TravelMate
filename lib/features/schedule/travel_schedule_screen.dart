import 'package:flutter/material.dart';
import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';

import 'package:travelmate/shared/models/saved_trip_preview.dart';
import 'package:travelmate/shared/widgets/travel_image_slider.dart';
import 'package:travelmate/shared/widgets/tag_section.dart';
import 'package:travelmate/shared/models/trip_tag.dart';
import 'package:travelmate/shared/state/saved_trip_preview_store.dart';
import 'package:travelmate/shared/widgets/save_trip_button.dart';
import 'package:travelmate/shared/widgets/trip_info_card.dart';

class TravelScheduleScreen extends StatelessWidget {
  final String tripId;
  final String tripName;
  final List<String> images;
  final List<TripTag> tags;
  final String destinationTitle;
  final String destinationDescription;

  const TravelScheduleScreen({
    super.key,
    required this.tripId,
    required this.tripName,
    required this.images,
    required this.tags,
    required this.destinationTitle,
    required this.destinationDescription,
  });

  SavedTripPreview _buildTripPreview() {
    return SavedTripPreview(
      tripName: tripName,
      destinationTitle: destinationTitle,
      description: destinationDescription,
      coverImage: images.isEmpty ? '' : images.first,
      tags: tags,
      bookmarkType: SavedBookmarkType.trip,
      sourceId: tripId,
    );
  }

  void _toggleTripBookmark(BuildContext context) {
    final nowSaved = SavedTripPreviewStore.instance.toggleBookmark(
      _buildTripPreview(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nowSaved
              ? 'Trip saved to Saved Items.'
              : 'Trip removed from Saved Items.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final tagPadding = EdgeInsets.symmetric(
      horizontal: sizes.padL,
      vertical: sizes.padS * 0.9,
    );
    final tagMinHeight = sizes.padL * 1.2;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          tripName,
          style: AppTextStyles.titleLg(sizes).copyWith(color: AppColors.yellow),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(sizes.padL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: TravelImageSlider(images: images),
              ),
              SizedBox(height: sizes.spaceS),
              Align(
                alignment: Alignment.centerRight,
                child: ValueListenableBuilder<List<SavedTripPreview>>(
                  valueListenable: SavedTripPreviewStore.instance,
                  builder: (context, _, _) {
                    final isSaved = SavedTripPreviewStore.instance.isSaved(
                      _buildTripPreview(),
                    );

                    return SaveTripButton(
                      isSaved: isSaved,
                      onTap: () => _toggleTripBookmark(context),
                    );
                  },
                ),
              ),
              TagSection(
                padding: EdgeInsets.only(top: sizes.spaceM),
                spacing: sizes.padM,
                runSpacing: sizes.padS,
                tagPadding: tagPadding,
                tagMinHeight: tagMinHeight,
                tags: tags,
              ),
              SizedBox(height: sizes.spaceM),
              TripInfoCard(
                title: destinationTitle,
                description: destinationDescription,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
