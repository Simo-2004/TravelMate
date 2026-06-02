import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';

class PersonalTagChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final int maxCharacters;
  final TextStyle? textStyle;
  final double? minHeight;

  const PersonalTagChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.padding,
    this.maxCharacters = 16,
    this.textStyle,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final resolvedRadius = borderRadius ?? sizes.radiusM;
    final resolvedPadding =
        padding ??
        EdgeInsets.symmetric(
          horizontal: sizes.padS,
          vertical: sizes.padXs * 0.6,
        );
    final resolvedBorderWidth = borderWidth ?? (sizes.padXs * 0.34);
    final resolvedLabel = _truncateLabel(label, maxCharacters);
    final resolvedTextStyle =
        textStyle ?? AppTextStyles.caption(sizes).copyWith(color: textColor);

    return Container(
      constraints: BoxConstraints(minHeight: minHeight ?? sizes.padL * 0.7),
      padding: resolvedPadding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(resolvedRadius),
        border: Border.all(
          color: borderColor ?? Colors.transparent,
          width: borderColor == null ? 0 : resolvedBorderWidth,
        ),
      ),
      child: Text(
        resolvedLabel,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: resolvedTextStyle,
      ),
    );
  }

  static String _truncateLabel(String text, int maxChars) {
    if (maxChars <= 0) {
      return '';
    }

    if (text.length <= maxChars) {
      return text;
    }

    if (maxChars <= 3) {
      return text.substring(0, maxChars);
    }

    return '${text.substring(0, maxChars - 3)}...';
  }
}
