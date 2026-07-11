import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';

/// Bottom message composer: a text field plus a yellow send button.
class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final ValueChanged<String>? onChanged;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.onChanged,
  });

  void _handleSend() {
    final text = controller.text;
    if (text.trim().isEmpty) {
      return;
    }

    onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

    return Material(
      color: AppColors.white,
      elevation: sizes.navElevation,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(sizes.padM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sizes.padM,
                    vertical: sizes.padS,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFCED),
                    borderRadius: BorderRadius.circular(sizes.radiusL),
                    border: Border.all(
                      color: const Color(0xFFFFE9A6),
                      width: sizes.padXs * 0.22,
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onChanged: onChanged,
                    onSubmitted: (_) => _handleSend(),
                    style: AppTextStyles.bodyMd(
                      sizes,
                    ).copyWith(color: AppColors.black),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: AppStrings.chatInputHint,
                      hintStyle: AppTextStyles.bodyMd(
                        sizes,
                      ).copyWith(color: AppColors.blackAlpha60),
                    ),
                  ),
                ),
              ),
              SizedBox(width: sizes.padS),
              _ChatSendButton(onTap: _handleSend),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatSendButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ChatSendButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

    // Fixed diameter (not derived from the row's live height) so it never
    // grows as the field expands for multiline text; centered in the row
    // so it stays visually aligned with the field's single-line height.
    final size = sizes.padL * 1.85;

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: AppColors.yellow,
        elevation: sizes.buttonElevation,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: Icon(
              Icons.send_rounded,
              color: AppColors.black,
              size: sizes.iconM * 0.85,
            ),
          ),
        ),
      ),
    );
  }
}
