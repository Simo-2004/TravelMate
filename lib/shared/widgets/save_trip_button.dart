import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';

class SaveTripButton extends StatelessWidget {
  final VoidCallback onTap;
  final String iconAsset;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? borderColor;
  final double? size;
  final double? iconSize;

  const SaveTripButton({
    super.key,
    required this.onTap,
    this.iconAsset = 'assets/icons/Bookmark.svg',
    this.backgroundColor,
    this.iconColor,
    this.borderColor,
    this.size,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final resolvedSize = size ?? sizes.padL * 1.62;
    final resolvedIconSize = iconSize ?? sizes.iconM * 0.93;

    return SizedBox(
      width: resolvedSize,
      height: resolvedSize,
      child: Material(
        color: backgroundColor ?? const Color(0xFFFFFCED),
        elevation: sizes.buttonElevation,
        shape: CircleBorder(
          side: BorderSide(
            color: borderColor ?? const Color(0xFFFFE9A6),
            width: sizes.padXs * 0.24,
          ),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: SvgPicture.asset(
              iconAsset,
              width: resolvedIconSize,
              height: resolvedIconSize,
              colorFilter: ColorFilter.mode(
                iconColor ?? AppColors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
