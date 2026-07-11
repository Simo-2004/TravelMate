import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';

/// Small dot + label indicating whether a mate is currently online.
class ChatOnlineStatus extends StatelessWidget {
  final bool isOnline;

  const ChatOnlineStatus({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final dotColor = isOnline ? AppColors.onlineGreen : AppColors.blackAlpha60;
    final label = isOnline
        ? AppStrings.chatOnlineLabel
        : AppStrings.chatOfflineLabel;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: sizes.padXs * 1.6,
          height: sizes.padXs * 1.6,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        SizedBox(width: sizes.padXs),
        Text(
          label,
          style: AppTextStyles.caption(sizes).copyWith(
            fontWeight: FontWeight.normal,
            color: AppColors.blackAlpha60,
          ),
        ),
      ],
    );
  }
}
