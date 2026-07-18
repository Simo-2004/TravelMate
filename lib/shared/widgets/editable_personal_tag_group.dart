import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
import 'package:travelmate/shared/models/trip_tag.dart';
import 'package:travelmate/shared/widgets/app_text_field.dart';
import 'package:travelmate/shared/widgets/personal_tag_group.dart';
import 'package:travelmate/shared/widgets/settings_action_button.dart';

class EditablePersonalTagGroup extends StatelessWidget {
  final String title;
  final String fieldLabel;
  final String emptyText;
  final TextEditingController inputController;
  final List<String> tags;
  final int paletteOffset;
  final VoidCallback onAddPressed;
  final ValueChanged<String> onRemoveTag;

  const EditablePersonalTagGroup({
    super.key,
    required this.title,
    required this.fieldLabel,
    required this.emptyText,
    required this.inputController,
    required this.tags,
    required this.onAddPressed,
    required this.onRemoveTag,
    this.paletteOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final resolvedTags = PersonalTagPalette.buildFromLabels(
      tags,
      offset: paletteOffset,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyMd(
            sizes,
          ).copyWith(color: AppColors.black, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: sizes.padS),
        AppTextField(
          controller: inputController,
          label: fieldLabel,
          onSubmitted: (_) => onAddPressed(),
        ),
        SizedBox(height: sizes.padS),
        SettingsActionButton(
          label: 'Add personal tag',
          color: AppColors.yellow,
          textColor: AppColors.black,
          iconColor: AppColors.yellow,
          onTap: onAddPressed,
          minHeight: (sizes.padL * 0.85).clamp(40.0, 64.0),
        ),
        SizedBox(height: sizes.padS),
        if (resolvedTags.isEmpty)
          Text(
            emptyText,
            style: AppTextStyles.bodyMd(
              sizes,
            ).copyWith(color: AppColors.blackAlpha60),
          ),
        if (resolvedTags.isNotEmpty)
          Wrap(
            spacing: sizes.padS,
            runSpacing: sizes.padS,
            children: resolvedTags
                .map(
                  (tag) => _EditablePersonalTagChip(
                    tag: tag,
                    onRemove: () => onRemoveTag(tag.label),
                  ),
                )
                .toList(growable: false),
          ),
      ],
    );
  }
}

class _EditablePersonalTagChip extends StatelessWidget {
  final TripTag tag;
  final VoidCallback onRemove;

  const _EditablePersonalTagChip({required this.tag, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(sizes.radiusM),
        onTap: onRemove,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: sizes.padS,
            vertical: sizes.padXs * 0.65,
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(sizes.radiusM),
            border: Border.all(
              color: tag.borderColor ?? AppColors.blackAlpha60,
              width: sizes.padXs * 0.34,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tag.label,
                style: AppTextStyles.caption(
                  sizes,
                ).copyWith(color: AppColors.black),
              ),
              SizedBox(width: sizes.padXs * 0.8),
              Icon(
                Icons.close_rounded,
                size: (sizes.textSm * 0.95).clamp(12.0, 18.0),
                color: AppColors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
