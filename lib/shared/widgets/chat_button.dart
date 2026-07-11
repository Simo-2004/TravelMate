import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';

/// Pill-shaped call-to-action button used to open a chat with another user.
class ChatButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  const ChatButton({
    super.key,
    required this.onTap,
    required this.label,
    this.icon = Icons.chat_bubble_rounded,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final resolvedBackground = backgroundColor ?? AppColors.yellow;
    final resolvedForeground = foregroundColor ?? AppColors.black;
    // A noticeably higher elevation than the flat default buttons in the
    // app use, so this pill reads as floating above the content rather
    // than sitting flush against it.
    final resolvedElevation = elevation ?? sizes.buttonElevation * 4;

    return Material(
      color: resolvedBackground,
      elevation: resolvedElevation,
      shadowColor: AppColors.black,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sizes.padL * 1.7,
            vertical: sizes.padM * 1.3,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: resolvedForeground, size: sizes.iconM),
              SizedBox(width: sizes.padS),
              Text(
                label,
                style: AppTextStyles.buttonLabel(
                  sizes,
                ).copyWith(color: resolvedForeground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
