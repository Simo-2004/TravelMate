import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';

class TravelSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? hintColor;
  final double? borderRadius;
  final String? iconAsset;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;

  const TravelSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText = AppStrings.searchHint,
    this.backgroundColor,
    this.textColor,
    this.hintColor,
    this.borderRadius,
    this.iconAsset,
    this.iconSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final resolvedBackground = backgroundColor ?? AppColors.yellow;
    final resolvedTextColor = textColor ?? AppColors.black;
    final resolvedHintColor = hintColor ?? AppColors.blackAlpha60;
    final resolvedRadius = borderRadius ?? sizes.radiusL;
    final resolvedPadding = padding ??
        EdgeInsets.symmetric(
          horizontal: sizes.padM,
          vertical: sizes.padS,
        );
    final resolvedIconSize = iconSize ?? sizes.iconM;
    final resolvedIconAsset = iconAsset ?? _defaultIconAsset;

    return Container(
      padding: resolvedPadding,
      decoration: BoxDecoration(
        color: resolvedBackground,
        borderRadius: BorderRadius.circular(resolvedRadius),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            resolvedIconAsset,
            width: resolvedIconSize,
            height: resolvedIconSize,
            colorFilter: ColorFilter.mode(resolvedTextColor, BlendMode.srcIn),
          ),
          SizedBox(width: sizes.padS),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppTextStyles.bodyMd(sizes).copyWith(
                color: resolvedTextColor,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: AppTextStyles.bodyMd(sizes).copyWith(
                  color: resolvedHintColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const String _defaultIconAsset = 'assets/icons/Search 2.svg';
}
