import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';

/// Tappable, underlined text link in the brand's light-blue accent — used for
/// secondary navigation such as "create a new account".
class LinkText extends StatelessWidget {
  const LinkText({super.key, required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMd(sizes).copyWith(
          color: AppColors.linkBlue,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.linkBlue,
        ),
      ),
    );
  }
}
