import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
import 'package:travelmate/shared/models/trip_tag.dart';
import 'package:travelmate/shared/widgets/tag_section.dart';

class _MateTagPaletteEntry {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const _MateTagPaletteEntry({
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });
}

class MateTagGroup extends StatelessWidget {
  static const List<_MateTagPaletteEntry> _defaultPalette = [
    _MateTagPaletteEntry(
      backgroundColor: Color(0xFFFFF700),
      textColor: Color(0xFF3A3200),
      borderColor: Color(0xFFFFF199),
    ),
    _MateTagPaletteEntry(
      backgroundColor: Color(0xFF00E5FF),
      textColor: Color(0xFF00343A),
      borderColor: Color(0xFF99F8FF),
    ),
    _MateTagPaletteEntry(
      backgroundColor: Color(0xFF7CFF4D),
      textColor: Color(0xFF1F3A00),
      borderColor: Color(0xFFC8FFB5),
    ),
    _MateTagPaletteEntry(
      backgroundColor: Color(0xFFFF9100),
      textColor: Color(0xFF4A2600),
      borderColor: Color(0xFFFFD299),
    ),
    _MateTagPaletteEntry(
      backgroundColor: Color(0xFFFF4FD8),
      textColor: Color(0xFF3A0032),
      borderColor: Color(0xFFFFC2EF),
    ),
    _MateTagPaletteEntry(
      backgroundColor: Color(0xFFB24CFF),
      textColor: Color(0xFF2F005C),
      borderColor: Color(0xFFE0B6FF),
    ),
  ];

  final String title;
  final List<String> tags;
  final EdgeInsetsGeometry? padding;
  final Color? tagBackgroundColor;
  final Color? tagTextColor;
  final Color? tagBorderColor;
  final EdgeInsetsGeometry? tagPadding;
  final double? tagMinHeight;
  final int paletteOffset;

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
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    final sizes = AppSizes.of(context);
    final resolvedPadding = padding ?? EdgeInsets.only(top: sizes.spaceM);
    final resolvedTagPadding = tagPadding ??
        EdgeInsets.symmetric(
          horizontal: sizes.padL,
          vertical: sizes.padS * 0.9,
        );
    final resolvedTagMinHeight = tagMinHeight ?? sizes.padL * 1.2;

    final tripTags = tags
        .asMap()
        .entries
        .map(
          (entry) {
            final index = entry.key;
            final tag = entry.value;
            final paletteIndex =
                (index + paletteOffset) % _defaultPalette.length;
            final palette = _defaultPalette[paletteIndex];

            return TripTag(
            label: tag,
            backgroundColor: tagBackgroundColor ?? palette.backgroundColor,
            textColor: tagTextColor ?? palette.textColor,
            borderColor: tagBorderColor ?? palette.borderColor,
          );
          },
        )
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
