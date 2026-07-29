import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  // Button properties that will change every time we use the button
  final String text;
  final VoidCallback onPressed;
  final Color? color; // ? = optional

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Theme.of(context).colorScheme.primary,
        foregroundColor: AppColors.white,
        padding: EdgeInsets.symmetric(
          horizontal: sizes.buttonH,
          vertical: sizes.buttonV,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sizes.radiusM),
        ),
        elevation: sizes.buttonElevation,
      ),
      onPressed: onPressed,
      child: Text(text, style: AppTextStyles.buttonLabel(sizes)),
    );
  }
}
