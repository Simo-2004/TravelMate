import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
import 'package:travelmate/shared/models/chat_message.dart';

/// Single chat bubble: yellow and right-aligned for the current user's
/// messages, neutral and left-aligned for the other participant's.
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final isFromMe = message.isFromMe;
    final backgroundColor = isFromMe
        ? AppColors.yellow
        : const Color(0xFFFFFCED);
    final borderColor = isFromMe
        ? AppColors.yellow
        : const Color(0xFFFFE9A6);
    final cornerRadius = sizes.radiusM;
    final tightCorner = sizes.padXs * 0.6;

    return Align(
      alignment: isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: sizes.padS),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: sizes.padM,
          vertical: sizes.padS,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: sizes.padXs * 0.22),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(cornerRadius),
            topRight: Radius.circular(cornerRadius),
            bottomLeft: Radius.circular(isFromMe ? cornerRadius : tightCorner),
            bottomRight: Radius.circular(
              isFromMe ? tightCorner : cornerRadius,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text,
              style: AppTextStyles.bodyMd(sizes).copyWith(
                color: AppColors.black,
              ),
            ),
            SizedBox(height: sizes.padXs * 0.5),
            Text(
              _formatTime(message.sentAt),
              style: AppTextStyles.caption(sizes).copyWith(
                fontSize: sizes.textSm * 0.8,
                fontWeight: FontWeight.normal,
                color: AppColors.blackAlpha60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
