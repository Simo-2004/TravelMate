import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';

/// Bookmark/flag toggle used on trip and mate detail screens.
///
/// A hollow circular outline frames a single flag icon; both the ring and the
/// icon fill communicate the saved state through color alone —
/// [AppColors.inactiveGray] when unsaved, [AppColors.yellow] when saved —
/// rather than swapping between a plain and a "barred" icon asset. The white
/// fill keeps the badge visible against any backdrop the button sits on.
class SaveTripButton extends StatelessWidget {
  final VoidCallback onTap;
  final String iconAsset;
  final bool isSaved;
  final double? size;
  final double? iconSize;

  const SaveTripButton({
    super.key,
    required this.onTap,
    this.iconAsset = 'assets/icons/Bookmark.svg',
    this.isSaved = false,
    this.size,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final resolvedSize = size ?? sizes.padL * 1.62;
    final resolvedIconSize = iconSize ?? sizes.iconM * 0.93;
    final resolvedColor = isSaved ? AppColors.yellow : AppColors.inactiveGray;

    return SizedBox(
      width: resolvedSize,
      height: resolvedSize,
      child: Material(
        color: AppColors.white,
        elevation: sizes.buttonElevation,
        shape: CircleBorder(
          side: BorderSide(color: resolvedColor, width: sizes.padXs * 0.32),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(
            child: SvgPicture.asset(
              iconAsset,
              width: resolvedIconSize,
              height: resolvedIconSize,
              colorFilter: ColorFilter.mode(resolvedColor, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}
