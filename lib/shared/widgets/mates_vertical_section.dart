import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/shared/models/mate_profile.dart';
import 'package:travelmate/shared/widgets/mate_card.dart';
import 'package:travelmate/shared/widgets/slider_section.dart';

class MatesVerticalSection extends StatelessWidget {
  final String title;
  final List<MateProfile> mates;
  final String emptyMessage;
  final ValueChanged<MateProfile>? onMateTap;
  final double? listHeight;
  final double? itemSpacing;

  const MatesVerticalSection({
    super.key,
    required this.title,
    required this.mates,
    required this.emptyMessage,
    this.onMateTap,
    this.listHeight,
    this.itemSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final resolvedListHeight = listHeight ?? sizes.scheduleSliderSize * 1.34;
    final resolvedItemSpacing = itemSpacing ?? sizes.padS * 1.2;
    final listView = ListView.separated(
      scrollDirection: Axis.vertical,
      itemCount: mates.length,
      separatorBuilder: (_, _) => SizedBox(height: resolvedItemSpacing),
      itemBuilder: (context, index) {
        final mate = mates[index];

        return MateCard(
          title: mate.name,
          description: mate.description,
          profileImageAsset: mate.profileImageAsset,
          onTap: onMateTap == null ? null : () => onMateTap!(mate),
        );
      },
    );
    final listContent = resolvedListHeight.isFinite
        ? SizedBox(
            height: resolvedListHeight,
            child: listView,
          )
        : Expanded(child: listView);

    return SliderSection(
      title: title,
      child: mates.isEmpty
          ? Padding(
              padding: EdgeInsets.only(top: sizes.padXs),
              child: Text(
                emptyMessage,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: sizes.textSm),
              ),
            )
          : listContent,
    );
  }
}
