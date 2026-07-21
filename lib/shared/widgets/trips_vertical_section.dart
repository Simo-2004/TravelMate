import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/shared/models/trip_tile_data.dart';
import 'package:travelmate/shared/widgets/mate_card.dart';
import 'package:travelmate/shared/widgets/slider_section.dart';

class TripsVerticalSection extends StatelessWidget {
  final String title;
  final List<TripTileData> trips;
  final String emptyMessage;
  final ValueChanged<TripTileData>? onTripTap;
  final double? listHeight;
  final double? itemSpacing;

  const TripsVerticalSection({
    super.key,
    required this.title,
    required this.trips,
    required this.emptyMessage,
    this.onTripTap,
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
      itemCount: trips.length,
      separatorBuilder: (_, _) => SizedBox(height: resolvedItemSpacing),
      itemBuilder: (context, index) {
        final trip = trips[index];

        return MateCard(
          title: trip.label,
          description: trip.description,
          profileImageAsset: trip.asset,
          onTap: onTripTap == null ? null : () => onTripTap!(trip),
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
      child: trips.isEmpty
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
