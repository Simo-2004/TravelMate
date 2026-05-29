import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
import 'package:travelmate/shared/models/search_research_mode.dart';

class SearchModeSwitchButton extends StatelessWidget {
  final SearchResearchMode mode;
  final VoidCallback onTap;
  final String tripsLabel;
  final String matesLabel;
  final String? tripsIconAsset;
  final String? matesIconAsset;
  final IconData tripsFallbackIcon;
  final IconData matesFallbackIcon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? labelColor;
  final double? size;
  final double? iconSize;
  final double? elevation;

  const SearchModeSwitchButton({
    super.key,
    required this.mode,
    required this.onTap,
    this.tripsLabel = 'Trips',
    this.matesLabel = 'Mates',
    this.tripsIconAsset,
    this.matesIconAsset,
    this.tripsFallbackIcon = Icons.flight_takeoff_rounded,
    this.matesFallbackIcon = Icons.people_alt_rounded,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.labelColor,
    this.size,
    this.iconSize,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final resolvedSize = size ?? sizes.padL * 2.2;
    final resolvedIconSize = iconSize ?? sizes.iconM * 0.98;
    final resolvedElevation = elevation ?? sizes.buttonElevation;
    final resolvedBackgroundColor = backgroundColor ?? AppColors.yellow;
    final resolvedBorderColor = borderColor ?? AppColors.yellow;
    final resolvedIconColor = iconColor ?? AppColors.black;
    final resolvedLabelColor = labelColor ?? AppColors.black;

    final isTripsMode = mode == SearchResearchMode.trips;
    final modeLabel = isTripsMode ? tripsLabel : matesLabel;
    final modeIconAsset = isTripsMode ? tripsIconAsset : matesIconAsset;
    final fallbackIcon = isTripsMode ? tripsFallbackIcon : matesFallbackIcon;

    return SizedBox(
      width: resolvedSize,
      height: resolvedSize,
      child: Material(
        color: resolvedBackgroundColor,
        elevation: resolvedElevation,
        shape: CircleBorder(
          side: BorderSide(
            color: resolvedBorderColor,
            width: sizes.padXs * 0.24,
          ),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sizes.padXs * 0.9),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ModeIcon(
                  iconAsset: modeIconAsset,
                  fallbackIcon: fallbackIcon,
                  iconSize: resolvedIconSize,
                  color: resolvedIconColor,
                ),
                SizedBox(height: sizes.padXs * 0.55),
                Text(
                  modeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(sizes).copyWith(
                    color: resolvedLabelColor,
                    fontSize: sizes.textSm * 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeIcon extends StatelessWidget {
  final String? iconAsset;
  final IconData fallbackIcon;
  final double iconSize;
  final Color color;

  const _ModeIcon({
    required this.iconAsset,
    required this.fallbackIcon,
    required this.iconSize,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = iconAsset;
    if (assetPath == null || assetPath.isEmpty) {
      return Icon(fallbackIcon, size: iconSize, color: color);
    }

    return FutureBuilder<bool>(
      future: _SvgAssetAvailabilityCache.exists(assetPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.data != true) {
          return Icon(fallbackIcon, size: iconSize, color: color);
        }

        return SvgPicture.asset(
          assetPath,
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        );
      },
    );
  }
}

class _SvgAssetAvailabilityCache {
  static final Map<String, Future<bool>> _cache = <String, Future<bool>>{};

  static Future<bool> exists(String assetPath) {
    return _cache.putIfAbsent(assetPath, () async {
      try {
        await rootBundle.load(assetPath);
        return true;
      } catch (_) {
        return false;
      }
    });
  }
}
