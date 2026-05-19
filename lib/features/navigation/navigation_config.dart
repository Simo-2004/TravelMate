import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/features/home/home_screen.dart';
import 'package:travelmate/features/saved/saved_items_screen.dart';
import 'package:travelmate/features/search/search_screen.dart';
import 'package:travelmate/features/settings/settings_screen.dart';

class NavigationItem {
  final String label;
  final String title;
  final IconData icon;
  final String? svgAsset;
  final Widget page;

  const NavigationItem({
    required this.label,
    required this.title,
    required this.icon,
    this.svgAsset,
    required this.page,
  });
}

class NavigationStyle {
  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry itemPadding;
  final BorderRadius itemRadius;
  final double iconSize;
  final double labelSpacing;
  final TextStyle selectedLabelStyle;
  final TextStyle unselectedLabelStyle;

  const NavigationStyle({
    required this.backgroundColor,
    required this.selectedColor,
    required this.unselectedColor,
    required this.elevation,
    required this.padding,
    required this.itemPadding,
    required this.itemRadius,
    required this.iconSize,
    required this.labelSpacing,
    required this.selectedLabelStyle,
    required this.unselectedLabelStyle,
  });

  Color iconColor(bool isSelected) {
    return isSelected ? selectedColor : unselectedColor;
  }

  TextStyle labelStyle(bool isSelected) {
    return isSelected ? selectedLabelStyle : unselectedLabelStyle;
  }
}

class NavigationConfig {
  final List<NavigationItem> items;
  final NavigationStyle style;
  final int initialIndex;

  const NavigationConfig({
    required this.items,
    required this.style,
    this.initialIndex = 0,
  });
}

class NavigationDefaults {
  static const NavigationStyle style = NavigationStyle(
    backgroundColor: AppColors.white,
    selectedColor: AppColors.yellow,
    unselectedColor: AppColors.black,
    elevation: AppSizes.navElevation,
    padding: EdgeInsets.symmetric(
      horizontal: AppSizes.padM,
      vertical: AppSizes.padS,
    ),
    itemPadding: EdgeInsets.symmetric(
      horizontal: AppSizes.padS,
      vertical: AppSizes.padXs,
    ),
    itemRadius: BorderRadius.all(Radius.circular(AppSizes.radiusM)),
    iconSize: AppSizes.iconM,
    labelSpacing: AppSizes.padXs,
    selectedLabelStyle: TextStyle(
      fontSize: AppSizes.textSm,
      fontWeight: FontWeight.bold,
      color: AppColors.yellow,
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: AppSizes.textSm,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
  );

  static const NavigationConfig config = NavigationConfig(
    items: [
      const NavigationItem(
        label: AppStrings.navHomeLabel,
        title: AppStrings.pageHomeTitle,
        icon: Icons.home,
        page: const HomeScreen(),
      ),
      const NavigationItem(
        label: AppStrings.navSearchLabel,
        title: AppStrings.pageSearchTitle,
        icon: Icons.search,
        page: const SearchScreen(),
      ),
      const NavigationItem(
        label: AppStrings.navSavedLabel,
        title: AppStrings.pageSavedTitle,
        icon: Icons.bookmark_border,
        page: const SavedItemsScreen(),
      ),
      const NavigationItem(
        label: AppStrings.navSettingsLabel,
        title: AppStrings.pageSettingsTitle,
        icon: Icons.settings,
        page: const SettingsScreen(),
      ),
    ],
    style: style,
  );
}
