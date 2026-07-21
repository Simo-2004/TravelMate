import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/features/schedule/travel_schedule_screen.dart';
import 'package:travelmate/features/search/mate_details_screen.dart';
import 'package:travelmate/shared/data/mate_catalog.dart';
import 'package:travelmate/shared/data/trip_catalog.dart';
import 'package:travelmate/shared/models/mate_profile.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
import 'package:travelmate/shared/models/saved_trip_preview.dart';
import 'package:travelmate/shared/models/trip_tile_data.dart';
import 'package:travelmate/shared/state/saved_trip_preview_store.dart';
import 'package:travelmate/shared/widgets/tag_section.dart';
import 'package:travelmate/shared/widgets/trip_info_card.dart';

/// Screen listing all saved trip and mate bookmarks.
class SavedItemsScreen extends StatelessWidget {
  static final List<TripTileData> _allTripTiles = [
    ...TripCatalog.trips,
    ...TripCatalog.recents,
  ];

  const SavedItemsScreen({super.key});

  void _openSavedItem(BuildContext context, SavedTripPreview item) {
    if (item.bookmarkType == SavedBookmarkType.mate) {
      final mate = _resolveMate(item) ?? _buildFallbackMate(item);
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => MateDetailsScreen(mate: mate)));
      return;
    }

    final trip = _resolveTrip(item);
    final fallbackImages = item.coverImage.isEmpty
        ? const <String>[]
        : <String>[item.coverImage];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TravelScheduleScreen(
          tripId: trip?.tripId ?? item.sourceId,
          tripName: trip?.label ?? item.tripName,
          images: trip?.scheduleImages ?? fallbackImages,
          tags: trip?.tags ?? item.tags,
          destinationTitle: trip?.destinationTitle ?? item.destinationTitle,
          destinationDescription: trip?.description ?? item.description,
        ),
      ),
    );
  }

  TripTileData? _resolveTrip(SavedTripPreview item) {
    final normalizedSourceId = item.sourceId.trim().toLowerCase();
    final normalizedTripName = item.tripName.trim().toLowerCase();
    final normalizedDestinationTitle = item.destinationTitle
        .trim()
        .toLowerCase();

    final tripById = TripCatalog.findTripById(normalizedSourceId);
    if (tripById != null) {
      return tripById;
    }

    if (normalizedSourceId.isNotEmpty) {
      for (final trip in _allTripTiles) {
        if (trip.label.toLowerCase() == normalizedSourceId) {
          return trip;
        }
      }
    }

    for (final trip in _allTripTiles) {
      if (trip.label.toLowerCase() == normalizedTripName) {
        return trip;
      }
    }

    if (normalizedSourceId.isNotEmpty) {
      return null;
    }

    for (final trip in _allTripTiles) {
      if (trip.destinationTitle.toLowerCase() == normalizedDestinationTitle) {
        return trip;
      }
    }

    return null;
  }

  MateProfile? _resolveMate(SavedTripPreview item) {
    final normalizedSourceId = item.sourceId.trim().toLowerCase();
    final normalizedName = item.tripName.trim().toLowerCase();

    for (final mate in MateCatalog.mates) {
      final matchesSourceId =
          normalizedSourceId.isNotEmpty &&
          mate.id.toLowerCase() == normalizedSourceId;
      final matchesName = mate.name.toLowerCase() == normalizedName;

      if (matchesSourceId || matchesName) {
        return mate;
      }
    }

    return null;
  }

  MateProfile _buildFallbackMate(SavedTripPreview item) {
    final tagLabels = item.tags
        .map((tag) => tag.label)
        .where((label) => label.trim().isNotEmpty)
        .toList(growable: false);

    final fallbackId = item.sourceId.trim().isNotEmpty
        ? item.sourceId
        : 'saved_mate_${item.tripName.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}';

    return MateProfile(
      id: fallbackId,
      name: item.tripName,
      description: item.description,
      profileImageAsset: item.coverImage.isEmpty ? null : item.coverImage,
      interests: tagLabels,
      preferredTrips: const [],
      keywords: tagLabels,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

    return ValueListenableBuilder<List<SavedTripPreview>>(
      valueListenable: SavedTripPreviewStore.instance,
      builder: (context, previews, _) {
        if (previews.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(sizes.padL),
              child: Text(
                'Tap the bookmark button in a schedule or mate profile to prepare a card for saving.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd(sizes),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(sizes.padL),
          itemCount: previews.length,
          separatorBuilder: (_, _) => SizedBox(height: sizes.spaceM),
          itemBuilder: (context, index) {
            final item = previews[index];

            return _SavedPreviewCard(
              item: item,
              onTap: () => _openSavedItem(context, item),
            );
          },
        );
      },
    );
  }
}

class _SavedPreviewCard extends StatelessWidget {
  final SavedTripPreview item;
  final VoidCallback onTap;

  const _SavedPreviewCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final hasCoverImage = item.coverImage.isNotEmpty;
    final isSvg = item.coverImage.toLowerCase().endsWith('.svg');
    final cardBorderRadius = BorderRadius.circular(sizes.radiusL);

    return Material(
      color: AppColors.white,
      borderRadius: cardBorderRadius,
      child: InkWell(
        borderRadius: cardBorderRadius,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(sizes.padM),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: cardBorderRadius,
            border: Border.all(
              color: AppColors.blackAlpha60,
              width: sizes.padXs * 0.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _PreviewImage(
                    imageAsset: item.coverImage,
                    hasCoverImage: hasCoverImage,
                    isSvg: isSvg,
                  ),
                  SizedBox(width: sizes.padM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.tripName,
                          style: AppTextStyles.titleLg(
                            sizes,
                          ).copyWith(fontSize: sizes.textMd),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: sizes.spaceS),
              TripInfoCard(
                title: item.destinationTitle,
                description: item.description,
              ),
              TagSection(
                padding: EdgeInsets.only(top: sizes.spaceS),
                spacing: sizes.padS,
                runSpacing: sizes.padXs,
                tagPadding: EdgeInsets.symmetric(
                  horizontal: sizes.padS,
                  vertical: sizes.padXs * 0.6,
                ),
                tagMinHeight: sizes.padL * 0.8,
                tags: item.tags,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewImage extends StatelessWidget {
  final String imageAsset;
  final bool hasCoverImage;
  final bool isSvg;

  const _PreviewImage({
    required this.imageAsset,
    required this.hasCoverImage,
    required this.isSvg,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final side = sizes.sliderTileSize * 0.36;

    return ClipRRect(
      borderRadius: BorderRadius.circular(sizes.radiusM),
      child: Container(
        width: side,
        height: side,
        color: const Color(0xFFFFFCED),
        child: !hasCoverImage
            ? Icon(
                Icons.bookmark_border,
                color: AppColors.blackAlpha60,
                size: sizes.iconM,
              )
            : isSvg
            ? SvgPicture.asset(imageAsset, fit: BoxFit.cover)
            : Image.asset(imageAsset, fit: BoxFit.cover),
      ),
    );
  }
}
