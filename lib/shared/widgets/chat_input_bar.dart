import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';

/// Bottom message composer: a text field, an optional attach button, and a
/// yellow send button.
class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onAttachTap;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.onChanged,
    this.onAttachTap,
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
              if (onAttachTap != null) ...[
                SizedBox(width: sizes.padS),
                _ChatRoundIconButton(
                  onTap: onAttachTap!,
                  icon: Icons.add_rounded,
                  tooltip: AppStrings.chatAttachTripTooltip,
                  size: sizes.padL * 1.5,
                  iconSize: sizes.iconM * 0.8,
                  backgroundColor: const Color(0xFFFFFCED),
                  borderColor: const Color(0xFFFFE9A6),
                ),
              ],
              SizedBox(width: sizes.padS),
              _ChatRoundIconButton(
                onTap: _handleSend,
                icon: Icons.send_rounded,
                // Fixed diameter (not derived from the row's live height) so
                // it never grows as the field expands for multiline text.
                size: sizes.padL * 1.85,
                iconSize: sizes.iconM * 0.85,
                backgroundColor: AppColors.yellow,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatRoundIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color? borderColor;
  final String? tooltip;

  const _ChatRoundIconButton({
    required this.onTap,
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.backgroundColor,
    this.borderColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final button = SizedBox(
      width: size,
      height: size,
      child: Material(
        color: backgroundColor,
        elevation: sizes.buttonElevation,
        shape: CircleBorder(
          side: borderColor == null
              ? BorderSide.none
              : BorderSide(
                  color: borderColor!,
                  width: sizes.padXs * 0.22,
                ),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: Icon(icon, color: AppColors.black, size: iconSize),
          ),
        ),
      ),
    );

    if (tooltip == null) {
      return button;
    }

    return Tooltip(message: tooltip!, child: button);
  }
}
