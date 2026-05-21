import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';

class AppTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.yellow,
      onPrimary: AppColors.black,
      primaryContainer: AppColors.yellow,
      onPrimaryContainer: AppColors.black,
      secondary: AppColors.yellow,
      onSecondary: AppColors.black,
      secondaryContainer: AppColors.yellow,
      onSecondaryContainer: AppColors.black,
      tertiary: AppColors.yellow,
      onTertiary: AppColors.black,
      tertiaryContainer: AppColors.yellow,
      onTertiaryContainer: AppColors.black,
      error: AppColors.black,
      onError: AppColors.white,
      errorContainer: AppColors.black,
      onErrorContainer: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.black,
      surfaceVariant: AppColors.white,
      onSurfaceVariant: AppColors.black,
      outline: AppColors.blackAlpha60,
      outlineVariant: AppColors.blackAlpha60,
      shadow: AppColors.black,
      scrim: AppColors.blackAlpha60,
      inverseSurface: AppColors.black,
      onInverseSurface: AppColors.white,
      inversePrimary: AppColors.yellow,
      surfaceTint: AppColors.yellow,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.white,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        surfaceTintColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
