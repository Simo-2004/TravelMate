import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
import 'package:travelmate/shared/data/mate_tag_palette.dart';
import 'package:travelmate/shared/data/trip_tag_catalog.dart';
import 'package:travelmate/shared/models/trip_tag.dart';
import 'package:travelmate/shared/widgets/tag_section.dart';

class MateTagGroup extends StatelessWidget {
  final String title;
  final List<String> tags;
  final EdgeInsetsGeometry? padding;
  final Color? tagBackgroundColor;
  final Color? tagTextColor;
  final Color? tagBorderColor;
  final EdgeInsetsGeometry? tagPadding;
  final double? tagMinHeight;
  final int paletteOffset;
  final bool matchTripTagCatalog;

  const MateTagGroup({
    super.key,
    required this.title,
    required this.tags,
    this.padding,
    this.tagBackgroundColor,
    this.tagTextColor,
    this.tagBorderColor,
    this.tagPadding,
    this.tagMinHeight,
    this.paletteOffset = 0,
    this.matchTripTagCatalog = false,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    final sizes = AppSizes.of(context);
    final resolvedPadding = padding ?? EdgeInsets.only(top: sizes.spaceM);
    final resolvedTagPadding =
        tagPadding ??
        EdgeInsets.symmetric(
          horizontal: sizes.padL,
          vertical: sizes.padS * 0.9,
        );
    final resolvedTagMinHeight = tagMinHeight ?? sizes.padL * 1.2;

    final tripTags = tags
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final tag = entry.value;

          // When this group mirrors real trip tags (e.g. a mate's
          // preferred trips), reuse the actual trip tag's colors instead
          // of the arbitrary cycling palette below, so the chip matches
          // how that same tag looks on a real trip.
          if (matchTripTagCatalog) {
            final catalogTag = TripTagCatalog.resolve(tag);
            if (catalogTag != null) {
              return TripTag(
                label: catalogTag.label,
                backgroundColor:
                    tagBackgroundColor ?? catalogTag.backgroundColor,
                textColor: tagTextColor ?? catalogTag.textColor,
                borderColor: tagBorderColor ?? catalogTag.borderColor,
              );
            }
          }

          final palette = MateTagPalette.resolve(index + paletteOffset);

          return TripTag(
            label: tag,
            backgroundColor: tagBackgroundColor ?? palette.backgroundColor,
            textColor: tagTextColor ?? palette.textColor,
            borderColor: tagBorderColor ?? palette.borderColor,
          );
        })
        .toList(growable: false);

    return Padding(
      padding: resolvedPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleLg(sizes).copyWith(
              fontSize: (sizes.textMd * 1.02).clamp(16.0, 26.0).toDouble(),
            ),
          ),
          TagSection(
            tags: tripTags,
            padding: EdgeInsets.only(top: sizes.padS),
            spacing: sizes.padM,
            runSpacing: sizes.padS,
            tagPadding: resolvedTagPadding,
            tagMinHeight: resolvedTagMinHeight,
          ),
        ],
      ),
    );
  }
}
