import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';

class MateDetailsPanel extends StatelessWidget {
  final String name;
  final String description;
  final String? profileImageAsset;
  final Widget? profileImage;
  final EdgeInsetsGeometry? padding;
  final double? avatarSize;
  final TextStyle? nameStyle;
  final TextStyle? descriptionStyle;
  final Widget? nameTrailing;
  final double? imageToTitleSpacing;
  final EdgeInsetsGeometry? descriptionPadding;
  final Color? descriptionBackgroundColor;
  final Color? descriptionBorderColor;
  final double? descriptionBorderWidth;
  final double? descriptionBorderRadius;

  const MateDetailsPanel({
    super.key,
    required this.name,
    required this.description,
    this.profileImageAsset,
    this.profileImage,
    this.padding,
    this.avatarSize,
    this.nameStyle,
    this.descriptionStyle,
    this.nameTrailing,
    this.imageToTitleSpacing,
    this.descriptionPadding,
    this.descriptionBackgroundColor,
    this.descriptionBorderColor,
    this.descriptionBorderWidth,
    this.descriptionBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final resolvedPadding =
        padding ?? EdgeInsets.symmetric(vertical: sizes.padS);
    final resolvedImageToTitleSpacing =
        imageToTitleSpacing ?? (sizes.padM * 1.45);
    final resolvedNameStyle =
        nameStyle ??
        AppTextStyles.titleLg(sizes).copyWith(
          fontSize: (sizes.textMd * 1.22).clamp(19.0, 30.0).toDouble(),
          height: sizes.textHeightTight + 0.05,
        );
    final resolvedDescriptionStyle =
        descriptionStyle ??
        AppTextStyles.bodyMd(sizes).copyWith(
          fontSize: (sizes.textSm * 1.26).clamp(14.0, 20.0).toDouble(),
          height: sizes.textHeightTight + 0.1,
        );
    final resolvedDescriptionPadding =
        descriptionPadding ??
        EdgeInsets.symmetric(horizontal: sizes.padM, vertical: sizes.padS);
    final resolvedDescriptionBackgroundColor =
        descriptionBackgroundColor ?? const Color(0xFFFFFCED);
    final resolvedDescriptionBorderColor =
        descriptionBorderColor ?? AppColors.blackAlpha60;
    final resolvedDescriptionBorderWidth =
        descriptionBorderWidth ?? sizes.padXs * 0.22;
    final resolvedDescriptionBorderRadius =
        descriptionBorderRadius ?? sizes.radiusM;
    final resolvedDescriptionInsets = resolvedDescriptionPadding.resolve(
      Directionality.of(context),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final baseAvatarSize =
            avatarSize ?? (sizes.sliderTileSize * 0.84).clamp(84.0, 150.0);
        final widthBasedMax = (constraints.maxWidth * 0.34)
            .clamp(84.0, 150.0)
            .toDouble();
        final resolvedAvatarSize = baseAvatarSize
            .clamp(84.0, widthBasedMax)
            .toDouble();

        return Padding(
          padding: resolvedPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(resolvedAvatarSize * 0.5),
                  child: Container(
                    width: resolvedAvatarSize,
                    height: resolvedAvatarSize,
                    color: const Color(0xFFFFFCED),
                    child: _buildProfileImage(
                      size: resolvedAvatarSize,
                      placeholderColor: AppColors.blackAlpha60,
                    ),
                  ),
                ),
              ),
              SizedBox(height: resolvedImageToTitleSpacing),
              Padding(
                padding: EdgeInsets.only(left: resolvedDescriptionInsets.left),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: resolvedNameStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (nameTrailing != null) ...[
                      SizedBox(width: sizes.padS),
                      nameTrailing!,
                    ],
                  ],
                ),
              ),
              SizedBox(height: sizes.padXs * 1.35),
              Container(
                width: double.infinity,
                padding: resolvedDescriptionPadding,
                decoration: BoxDecoration(
                  color: resolvedDescriptionBackgroundColor,
                  borderRadius: BorderRadius.circular(
                    resolvedDescriptionBorderRadius,
                  ),
                  border: Border.all(
                    color: resolvedDescriptionBorderColor,
                    width: resolvedDescriptionBorderWidth,
                  ),
                ),
                child: Text(description, style: resolvedDescriptionStyle),
              ),
            ],
          ),
        );
      },
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
      return SvgPicture.asset(asset, fit: BoxFit.cover);
    }

    return Image.asset(asset, fit: BoxFit.cover);
  }
}
