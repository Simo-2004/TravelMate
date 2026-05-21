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

  const NavigationStyle({
    required this.backgroundColor,
    required this.selectedColor,
    required this.unselectedColor,
  });

  double elevation(AppSizes sizes) {
    return sizes.navElevation;
  }

  EdgeInsets padding(AppSizes sizes) {
    return EdgeInsets.symmetric(
      horizontal: sizes.padM,
      vertical: sizes.padS,
    );
  }

  EdgeInsets itemPadding(AppSizes sizes) {
    return EdgeInsets.symmetric(
      horizontal: sizes.padS,
      vertical: sizes.padXs,
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
    backgroundColor: AppColors.white,
    selectedColor: AppColors.yellow,
    unselectedColor: AppColors.black,
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
