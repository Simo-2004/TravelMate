import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';

/// App logo above the "Travel Mate" wordmark, rendered in the brand yellow
/// (the same accent used by the bottom navigation bar). Reused wherever the
/// app needs to present its identity — currently the login screen.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.logoAsset = 'assets/logo.png'});

  final String logoAsset;

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final logoSize = (sizes.sliderTileSize * 1.15).clamp(96.0, 200.0).toDouble();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          logoAsset,
          width: logoSize,
          height: logoSize,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => SizedBox(
            width: logoSize,
            height: logoSize,
            child: Icon(
              Icons.travel_explore,
              size: logoSize * 0.6,
              color: AppColors.yellow,
            ),
          ),
        ),
        SizedBox(height: sizes.spaceS),
        Text(
          AppStrings.brandName,
          textAlign: TextAlign.center,
          style: AppTextStyles.titleLg(sizes).copyWith(
            color: AppColors.yellow,
            fontSize: (sizes.textLg * 1.15).clamp(28.0, 46.0).toDouble(),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
