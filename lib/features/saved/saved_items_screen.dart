import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
import 'package:travelmate/shared/models/saved_trip_preview.dart';
import 'package:travelmate/shared/state/saved_trip_preview_store.dart';
import 'package:travelmate/shared/widgets/tag_section.dart';
import 'package:travelmate/shared/widgets/trip_info_card.dart';

class SavedItemsScreen extends StatelessWidget {
  const SavedItemsScreen({super.key});

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
                'Tap the bookmark button in a schedule to prepare a card for saving.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd(sizes),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(sizes.padL),
          itemCount: previews.length,
          separatorBuilder: (_, __) => SizedBox(height: sizes.spaceM),
          itemBuilder: (context, index) {
            final item = previews[index];

            return _SavedPreviewCard(item: item);
          },
        );
      },
    );
  }
}

class _SavedPreviewCard extends StatelessWidget {
  final SavedTripPreview item;

  const _SavedPreviewCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final hasCoverImage = item.coverImage.isNotEmpty;
    final isSvg = item.coverImage.toLowerCase().endsWith('.svg');

    return Container(
      padding: EdgeInsets.all(sizes.padM),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(sizes.radiusL),
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
                      style: AppTextStyles.titleLg(sizes).copyWith(
                        fontSize: sizes.textMd,
                      ),
                    ),
                    SizedBox(height: sizes.padXs),
                    Text(
                      'Ready to save',
                      style: AppTextStyles.bodyMd(sizes),
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
                ? SvgPicture.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                  ),
      ),
    );
  }
}
