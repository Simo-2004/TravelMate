import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
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
  final Color selectedIndicatorColor;

  const NavigationStyle({
    required this.backgroundColor,
    required this.selectedColor,
    required this.unselectedColor,
    required this.selectedIndicatorColor,
  });

  double elevation(AppSizes sizes) {
    return sizes.navElevation;
  }

  EdgeInsets padding(AppSizes sizes) {
    return EdgeInsets.symmetric(
      horizontal: sizes.padM,
      vertical: sizes.padXs,
    );
  }

  EdgeInsets itemPadding(AppSizes sizes) {
    return EdgeInsets.symmetric(
      horizontal: sizes.padS,
      vertical: sizes.padXs * 0.5,
    );
  }

  BorderRadius itemRadius(AppSizes sizes) {
    return BorderRadius.all(Radius.circular(sizes.radiusM));
  }

  double iconSize(AppSizes sizes) {
    return sizes.iconM;
  }

  double labelSpacing(AppSizes sizes) {
    return sizes.padXs;
  }

  double indicatorPadding(AppSizes sizes) {
    return sizes.padS;
  }

  Color iconColor(bool isSelected) {
    return isSelected ? selectedColor : unselectedColor;
  }

  TextStyle labelStyle(AppSizes sizes, bool isSelected) {
    return AppTextStyles.navLabel(
      sizes,
      color: isSelected ? selectedColor : unselectedColor,
      weight: isSelected ? FontWeight.bold : FontWeight.w600,
    );
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
    backgroundColor: AppColors.yellow,
    selectedColor: AppColors.black,
    unselectedColor: AppColors.black,
    selectedIndicatorColor: AppColors.white,
  );

  static const NavigationConfig config = NavigationConfig(
    items: [
      const NavigationItem(
        label: AppStrings.navHomeLabel,
        title: AppStrings.pageHomeTitle,
        icon: Icons.home,
        svgAsset: 'assets/icons/airplane.svg',
        page: const HomeScreen(),
      ),
      const NavigationItem(
        label: AppStrings.navSearchLabel,
        title: AppStrings.pageSearchTitle,
        icon: Icons.search,
        svgAsset: 'assets/icons/Search 2.svg',
        page: const SearchScreen(),
      ),
      const NavigationItem(
        label: AppStrings.navSavedLabel,
        title: AppStrings.pageSavedTitle,
        icon: Icons.bookmark_border,
        svgAsset: 'assets/icons/Bookmark.svg',
        page: const SavedItemsScreen(),
      ),
      const NavigationItem(
        label: AppStrings.navSettingsLabel,
        title: AppStrings.pageSettingsTitle,
        icon: Icons.settings,
        svgAsset: 'assets/icons/Setting.svg',
        page: const SettingsScreen(),
      ),
    ],
    style: style,
  );
}
