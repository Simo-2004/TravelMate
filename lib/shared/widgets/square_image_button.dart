import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';

class SquareImageButton extends StatelessWidget {
  final String imageAsset;
  final String? label;
  final VoidCallback? onTap;
  final double? size;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? imageScale;
  final TextStyle? labelStyle;
  final double? labelSpacing;
  final BoxFit fit;

  const SquareImageButton({
    super.key,
    required this.imageAsset,
    this.label,
    this.onTap,
    this.size,
    this.borderRadius,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.imageScale,
    this.labelStyle,
    this.labelSpacing,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final side = size ?? sizes.sliderTileSize;
    final radius = borderRadius ?? sizes.radiusM;
    final resolvedPadding = padding ?? EdgeInsets.all(sizes.padXs);
    final resolvedBackground = backgroundColor ?? AppColors.white;
    final resolvedBorderColor = borderColor ?? AppColors.blackAlpha60;
    final resolvedBorderWidth = borderWidth ?? (sizes.padXs * 0.25);
    final resolvedImageScale = imageScale ?? sizes.sliderImageScale;
    final resolvedLabelStyle = labelStyle ?? AppTextStyles.caption(sizes);
    final resolvedLabelSpacing = labelSpacing ?? sizes.padXs;
    final isSvg = imageAsset.toLowerCase().endsWith('.svg');

    return SizedBox(
      width: side,
      height: side,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: resolvedBackground,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: resolvedBorderColor,
              width: resolvedBorderWidth,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: Padding(
              padding: resolvedPadding,
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: FractionallySizedBox(
                        widthFactor: resolvedImageScale,
                        heightFactor: resolvedImageScale,
                        child: isSvg
                            ? SvgPicture.asset(imageAsset, fit: fit)
                            : Image.asset(imageAsset, fit: fit),
                      ),
                    ),
                  ),
                  if (label != null)
                    Padding(
                      padding: EdgeInsets.only(top: resolvedLabelSpacing),
                      child: Text(
                        label!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: resolvedLabelStyle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
