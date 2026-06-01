import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';

class SettingsActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? iconAsset;
  final Color? textColor;
  final Color? iconColor;
  final Color? borderColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final double? minHeight;
  final double? iconSize;

  const SettingsActionButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    this.iconAsset,
    this.textColor,
    this.iconColor,
    this.borderColor,
    this.backgroundColor,
    this.padding,
    this.minHeight,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final resolvedTextColor = textColor ?? color;
    final resolvedIconColor = iconColor ?? resolvedTextColor;
    final resolvedBorderColor = borderColor ?? color;
    final resolvedIconSize = iconSize ?? (sizes.iconM * 0.82);
    final resolvedPadding =
        padding ??
        EdgeInsets.symmetric(horizontal: sizes.padM, vertical: sizes.padS);

    return Material(
      color: backgroundColor ?? AppColors.white,
      borderRadius: BorderRadius.circular(sizes.radiusM),
      child: InkWell(
        borderRadius: BorderRadius.circular(sizes.radiusM),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: minHeight ?? (sizes.padL * 0.95).clamp(44.0, 72.0),
          ),
          child: Container(
            padding: resolvedPadding,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.white,
              borderRadius: BorderRadius.circular(sizes.radiusM),
              border: Border.all(
                color: resolvedBorderColor,
                width: sizes.padXs * 0.24,
              ),
            ),
            child: Row(
              children: [
                if (iconAsset != null && iconAsset!.trim().isNotEmpty) ...[
                  SvgPicture.asset(
                    iconAsset!,
                    width: resolvedIconSize,
                    height: resolvedIconSize,
                    colorFilter: ColorFilter.mode(
                      resolvedIconColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: sizes.padS),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.buttonLabel(
                      sizes,
                    ).copyWith(color: resolvedTextColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
