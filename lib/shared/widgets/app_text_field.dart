import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';

/// Outlined, filled text field with the app's standard label/border styling.
/// Shared by the profile fields and the personal tag input so the decoration
/// lives in exactly one place.
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final int minLines;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? errorText;
  final ValueChanged<String>? onSubmitted;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.minLines = 1,
    this.obscureText = false,
    this.keyboardType,
    this.errorText,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(sizes.radiusM),
      borderSide: BorderSide(
        color: AppColors.blackAlpha60,
        width: sizes.padXs * 0.2,
      ),
    );

    return TextField(
      controller: controller,
      maxLines: obscureText ? 1 : maxLines,
      minLines: obscureText ? 1 : minLines,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        labelStyle: AppTextStyles.bodyMd(
          sizes,
        ).copyWith(color: AppColors.blackAlpha60),
        filled: true,
        fillColor: const Color(0xFFFFFCED),
        contentPadding: EdgeInsets.symmetric(
          horizontal: sizes.padM,
          vertical: sizes.padS,
        ),
        border: defaultBorder,
        enabledBorder: defaultBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(sizes.radiusM),
          borderSide: BorderSide(
            color: AppColors.yellow,
            width: sizes.padXs * 0.3,
          ),
        ),
      ),
    );
  }
}
