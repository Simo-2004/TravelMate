import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';

class MateCard extends StatelessWidget {
  final String title;
  final String description;
  final String? profileImageAsset;
  final Widget? profileImage;
  final VoidCallback? onTap;
  final double? height;
  final double? borderRadius;
  final double? profileImageSize;
  final double? profileImageRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final double? textSpacing;
  final BoxFit imageFit;
  final Color? imagePlaceholderColor;

  const MateCard({
    super.key,
    required this.title,
    required this.description,
    this.profileImageAsset,
    this.profileImage,
    this.onTap,
    this.height,
    this.borderRadius,
    this.profileImageSize,
    this.profileImageRadius,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.titleStyle,
    this.descriptionStyle,
    this.textSpacing,
    this.imageFit = BoxFit.cover,
    this.imagePlaceholderColor,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final defaultHeight =
      (sizes.sliderTileSize * 0.98).clamp(110.0, 180.0).toDouble();
    final resolvedHeight = height ?? defaultHeight;
    final resolvedBorderRadius = borderRadius ?? sizes.radiusL;
    final resolvedPadding = padding ??
        EdgeInsets.symmetric(
        horizontal: sizes.padM * 1.1,
        vertical: sizes.padS * 1.15,
        );
    final defaultProfileImageSize =
      (resolvedHeight * 0.72).clamp(76.0, 130.0).toDouble();
    final resolvedProfileImageSize =
      profileImageSize ?? defaultProfileImageSize;
    final resolvedProfileImageRadius = profileImageRadius ??
        resolvedProfileImageSize * 0.5;
    final resolvedTextSpacing = textSpacing ?? sizes.padXs * 1.25;
    final resolvedBackgroundColor = backgroundColor ?? AppColors.white;
    final resolvedBorderColor = borderColor ?? AppColors.blackAlpha60;
    final resolvedBorderWidth = borderWidth ?? sizes.padXs * 0.22;
    final defaultTitleFontSize =
      (sizes.textMd * 1.14).clamp(16.0, 22.0).toDouble();
    final defaultDescriptionFontSize =
      (sizes.textSm * 1.22).clamp(13.5, 18.0).toDouble();
    final resolvedTitleStyle = titleStyle ??
        AppTextStyles.titleLg(sizes).copyWith(
        fontSize: defaultTitleFontSize,
        height: sizes.textHeightTight + 0.06,
        );
    final resolvedDescriptionStyle = descriptionStyle ??
        AppTextStyles.bodyMd(sizes).copyWith(
        fontSize: defaultDescriptionFontSize,
        height: sizes.textHeightTight + 0.08,
        );

    return SizedBox(
      width: double.infinity,
      height: resolvedHeight,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: resolvedBackgroundColor,
            borderRadius: BorderRadius.circular(resolvedBorderRadius),
            border: Border.all(
              color: resolvedBorderColor,
              width: resolvedBorderWidth,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(resolvedBorderRadius),
            child: Padding(
              padding: resolvedPadding,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      resolvedProfileImageRadius,
                    ),
                    child: Container(
                      width: resolvedProfileImageSize,
                      height: resolvedProfileImageSize,
                      color: const Color(0xFFFFFCED),
                      child: _buildProfileImage(
                        size: resolvedProfileImageSize,
                        placeholderColor:
                            imagePlaceholderColor ?? AppColors.blackAlpha60,
                      ),
                    ),
                  ),
                  SizedBox(width: sizes.padM * 1.15),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: resolvedTitleStyle,
                        ),
                        SizedBox(height: resolvedTextSpacing),
                        Text(
                          description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: resolvedDescriptionStyle,
                        ),
                      ],
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

  Widget _buildProfileImage({
    required double size,
    required Color placeholderColor,
  }) {
    if (profileImage != null) {
      return profileImage!;
    }

    final asset = profileImageAsset;
    if (asset == null || asset.isEmpty) {
      return Center(
        child: Icon(
          Icons.person_outline,
          size: size * 0.46,
          color: placeholderColor,
        ),
      );
    }

    final isSvg = asset.toLowerCase().endsWith('.svg');
    if (isSvg) {
      return SvgPicture.asset(
        asset,
        fit: imageFit,
      );
    }

    return Image.asset(
      asset,
      fit: imageFit,
    );
  }
}
