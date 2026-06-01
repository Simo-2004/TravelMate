import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/shared/models/personal_tag.dart';
import 'package:travelmate/shared/widgets/personal_tag_chip.dart';

class PersonalTagSection extends StatelessWidget {
  final List<PersonalTag> tags;
  final EdgeInsetsGeometry? padding;
  final double? spacing;
  final double? runSpacing;
  final AlignmentGeometry alignment;
  final WrapAlignment wrapAlignment;
  final EdgeInsetsGeometry? tagPadding;
  final double? tagMinHeight;
  final int maxCharacters;
  final TextStyle? tagTextStyle;

  const PersonalTagSection({
    super.key,
    required this.tags,
    this.padding,
    this.spacing,
    this.runSpacing,
    this.alignment = Alignment.centerLeft,
    this.wrapAlignment = WrapAlignment.start,
    this.tagPadding,
    this.tagMinHeight,
    this.maxCharacters = 16,
    this.tagTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final resolvedPadding = padding ?? EdgeInsets.only(top: sizes.spaceS);
    final resolvedSpacing = spacing ?? sizes.padS;
    final resolvedRunSpacing = runSpacing ?? sizes.padXs;

    return Padding(
      padding: resolvedPadding,
      child: Align(
        alignment: alignment,
        child: Wrap(
          spacing: resolvedSpacing,
          runSpacing: resolvedRunSpacing,
          alignment: wrapAlignment,
          children: tags
              .map(
                (tag) => PersonalTagChip(
                  label: tag.label,
                  backgroundColor: tag.backgroundColor,
                  textColor: tag.textColor,
                  borderColor: tag.borderColor,
                  padding: tagPadding,
                  minHeight: tagMinHeight,
                  maxCharacters: maxCharacters,
                  textStyle: tagTextStyle,
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}
