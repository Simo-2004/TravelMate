import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';

class AppTextStyles {
  static TextStyle titleLg(AppSizes sizes) {
    return TextStyle(
      fontSize: sizes.textLg,
      fontWeight: FontWeight.bold,
      color: AppColors.black,
    );
  }

  static TextStyle bodyMd(AppSizes sizes) {
    return TextStyle(
      fontSize: sizes.textMd,
      color: AppColors.blackAlpha60,
    );
  }

  static TextStyle buttonLabel(AppSizes sizes) {
    return TextStyle(
      fontSize: sizes.textMd,
      fontWeight: FontWeight.bold,
      color: AppColors.white,
      height: sizes.textHeightTight,
    );
  }

  static TextStyle navLabel(
    AppSizes sizes, {
    required Color color,
    required FontWeight weight,
  }) {
    return TextStyle(
      fontSize: sizes.textSm,
      fontWeight: weight,
      height: sizes.textHeightTight,
      color: color,
    );
  }
}
