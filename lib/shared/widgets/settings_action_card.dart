import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';

class SettingsActionCard extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final double? minHeight;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;

  const SettingsActionCard({
    super.key,
    this.child,
    this.padding,
    this.minHeight,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final resolvedPadding = padding ?? EdgeInsets.all(sizes.padM);
    final resolvedMinHeight =
        minHeight ?? (sizes.padL * 1.5).clamp(72.0, 128.0);
    final resolvedRadius = borderRadius ?? sizes.radiusL;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: resolvedMinHeight.toDouble()),
      padding: resolvedPadding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(resolvedRadius),
        border: Border.all(
          color: borderColor ?? const Color(0x33000000),
          width: sizes.padXs * 0.22,
        ),
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }
}
