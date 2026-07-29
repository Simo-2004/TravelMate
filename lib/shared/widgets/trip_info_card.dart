import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';

class TripInfoCard extends StatelessWidget {
  final String title;
  final String description;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? titleSpacing;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;

  const TripInfoCard({
    super.key,
    required this.title,
    required this.description,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.titleSpacing,
    this.titleStyle,
    this.descriptionStyle,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final resolvedRadius = borderRadius ?? sizes.radiusL;
    final resolvedPadding = padding ?? EdgeInsets.all(sizes.padM);
    final resolvedTitleSpacing = titleSpacing ?? sizes.padS;
    final resolvedTitleStyle =
        titleStyle ??
        AppTextStyles.titleLg(
          sizes,
        ).copyWith(color: AppColors.black, fontSize: sizes.textMd);
    final resolvedDescriptionStyle =
        descriptionStyle ??
        AppTextStyles.bodyMd(sizes).copyWith(color: AppColors.blackAlpha60);

    return Container(
      width: double.infinity,
      padding: resolvedPadding,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFFFFCED),
        borderRadius: BorderRadius.circular(resolvedRadius),
        border: Border.all(
          color: borderColor ?? const Color(0xFFFFE9A6),
          width: sizes.padXs * 0.22,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: resolvedTitleStyle),
          SizedBox(height: resolvedTitleSpacing),
          Text(description, style: resolvedDescriptionStyle),
        ],
      ),
    );
  }
}
