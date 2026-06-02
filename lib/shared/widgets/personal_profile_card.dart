import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
import 'package:travelmate/shared/models/personal_profile.dart';

class PersonalProfileCard extends StatelessWidget {
  final PersonalProfile profile;
  final EdgeInsetsGeometry? padding;
  final double? avatarSize;
  final TextStyle? nameStyle;
  final TextStyle? descriptionStyle;
  final bool showAvatar;
  final bool showName;

  const PersonalProfileCard({
    super.key,
    required this.profile,
    this.padding,
    this.avatarSize,
    this.nameStyle,
    this.descriptionStyle,
    this.showAvatar = true,
    this.showName = true,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final resolvedPadding =
        padding ??
        EdgeInsets.symmetric(horizontal: sizes.padL, vertical: sizes.padL);
    final resolvedAvatarSize =
        avatarSize ?? (sizes.sliderTileSize * 0.55).clamp(96.0, 168.0);
    final resolvedNameStyle =
        nameStyle ??
        AppTextStyles.titleLg(sizes).copyWith(
          fontSize: (sizes.textMd * 1.12).clamp(18.0, 30.0).toDouble(),
        );
    final resolvedDescriptionStyle =
        descriptionStyle ??
        AppTextStyles.bodyMd(sizes).copyWith(
          fontSize: (sizes.textSm * 1.12).clamp(14.0, 20.0).toDouble(),
          height: sizes.textHeightTight + 0.15,
        );
    final hasIdentity = showAvatar || showName;

    return Container(
      width: double.infinity,
      padding: resolvedPadding,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCED),
        borderRadius: BorderRadius.circular(sizes.radiusL),
        border: Border.all(
          color: AppColors.blackAlpha60,
          width: sizes.padXs * 0.22,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAvatar)
            Align(
              alignment: Alignment.topCenter,
              child: _ProfileAvatar(
                photoAsset: profile.photoAsset,
                size: resolvedAvatarSize.toDouble(),
              ),
            ),
          if (showAvatar && showName) SizedBox(height: sizes.spaceS),
          if (showName)
            Align(
              alignment: Alignment.center,
              child: Text(
                profile.fullName,
                textAlign: TextAlign.center,
                style: resolvedNameStyle,
              ),
            ),
          if (hasIdentity) SizedBox(height: sizes.padXs * 1.4),
          Text(profile.description, style: resolvedDescriptionStyle),
        ],
      ),
    );
  }
}

class ProfileIdentityHeader extends StatelessWidget {
  final PersonalProfile profile;
  final EdgeInsetsGeometry? padding;
  final double? avatarSize;
  final TextStyle? nameStyle;

  const ProfileIdentityHeader({
    super.key,
    required this.profile,
    this.padding,
    this.avatarSize,
    this.nameStyle,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final resolvedPadding = padding ?? EdgeInsets.zero;
    final resolvedAvatarSize =
        avatarSize ?? (sizes.sliderTileSize * 0.55).clamp(96.0, 168.0);
    final resolvedNameStyle =
        nameStyle ??
        AppTextStyles.titleLg(sizes).copyWith(
          fontSize: (sizes.textMd * 1.12).clamp(18.0, 30.0).toDouble(),
        );

    return Padding(
      padding: resolvedPadding,
      child: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _ProfileAvatar(
              photoAsset: profile.photoAsset,
              size: resolvedAvatarSize.toDouble(),
            ),
          ),
          SizedBox(height: sizes.spaceS),
          Text(
            profile.fullName,
            textAlign: TextAlign.center,
            style: resolvedNameStyle,
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String photoAsset;
  final double size;

  const _ProfileAvatar({required this.photoAsset, required this.size});

  @override
  Widget build(BuildContext context) {
    final asset = photoAsset.trim();
    final isSvg = asset.toLowerCase().endsWith('.svg');

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.5),
      child: Container(
        width: size,
        height: size,
        color: AppColors.white,
        child: asset.isEmpty
            ? Icon(
                Icons.person_outline,
                color: AppColors.blackAlpha60,
                size: size * 0.46,
              )
            : isSvg
            ? SvgPicture.asset(asset, fit: BoxFit.cover)
            : Image.asset(asset, fit: BoxFit.cover),
      ),
    );
  }
}
