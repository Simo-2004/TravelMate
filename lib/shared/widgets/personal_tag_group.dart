import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
import 'package:travelmate/shared/models/trip_tag.dart';
import 'package:travelmate/shared/widgets/tag_section.dart';

class PersonalTagPalette {
  static const List<Color> strokeColors = [
    Color(0xFFE3D200),
    Color(0xFF00BBD1),
    Color(0xFF4EBC2B),
    Color(0xFFE67E00),
    Color(0xFFD93FB8),
    Color(0xFF8C3CE0),
  ];

  static TripTag tagFromLabel(String label, int index) {
    final paletteIndex = index % strokeColors.length;

    return TripTag(
      label: label,
      backgroundColor: Colors.transparent,
      textColor: AppColors.black,
      borderColor: strokeColors[paletteIndex],
    );
  }

  static List<TripTag> buildFromLabels(List<String> labels, {int offset = 0}) {
    return labels
        .asMap()
        .entries
        .map((entry) => tagFromLabel(entry.value, entry.key + offset))
        .toList(growable: false);
  }
}

class PersonalTagGroup extends StatelessWidget {
  final String title;
  final List<String> tags;
  final EdgeInsetsGeometry? padding;
  final Color? tagBorderColor;
  final EdgeInsetsGeometry? tagPadding;
  final double? tagMinHeight;
  final int paletteOffset;

  const PersonalTagGroup({
    super.key,
    required this.title,
    required this.tags,
    this.padding,
    this.tagBorderColor,
    this.tagPadding,
    this.tagMinHeight,
    this.paletteOffset = 0,
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

    final personalTags = tags
        .asMap()
        .entries
        .map((entry) {
          final baseTag = PersonalTagPalette.tagFromLabel(
            entry.value,
            entry.key + paletteOffset,
          );

          return TripTag(
            label: baseTag.label,
            backgroundColor: Colors.transparent,
            textColor: AppColors.black,
            borderColor: tagBorderColor ?? baseTag.borderColor,
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
            tags: personalTags,
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
