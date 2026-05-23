import 'package:flutter/material.dart';
import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';

import 'package:travelmate/shared/widgets/travel_image_slider.dart';
import 'package:travelmate/shared/widgets/tag_section.dart';
import 'package:travelmate/shared/models/trip_tag.dart';

class TravelScheduleScreen extends StatelessWidget {
  final String tripName;
  final List<String> images;
  final List<TripTag> tags;

  const TravelScheduleScreen({
    super.key,
    required this.tripName,
    required this.images,
    required this.tags,
  });

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
          style: AppTextStyles.titleLg(sizes).copyWith(
            color: AppColors.yellow,
          ),
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
                child: TravelImageSlider(
                  images: images,
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
            ],
          ),
        ),
      ),
    );
  }
}
