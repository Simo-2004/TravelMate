import 'package:flutter/material.dart';
import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';

import 'package:travelmate/shared/widgets/travel_image_slider.dart';

class TravelScheduleScreen extends StatelessWidget {
  final String tripName;
  final List<String> images;

  const TravelScheduleScreen({
    super.key,
    required this.tripName,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

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
            ],
          ),
        ),
      ),
    );
  }
}
