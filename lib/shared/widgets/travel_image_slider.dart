import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';

class TravelImageSlider extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final double? size;
  final double? borderRadius;
  final Color? backgroundColor;
  final BoxFit fit;
  final EdgeInsetsGeometry? indicatorPadding;
  final TextStyle? indicatorTextStyle;

  const TravelImageSlider({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.size,
    this.borderRadius,
    this.backgroundColor,
    this.fit = BoxFit.cover,
    this.indicatorPadding,
    this.indicatorTextStyle,
  });

  @override
  State<TravelImageSlider> createState() => _TravelImageSliderState();
}

class _TravelImageSliderState extends State<TravelImageSlider> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    if (widget.images.isEmpty) {
      _currentIndex = 0;
      _controller = PageController();
      return;
    }

    _currentIndex = widget.initialIndex.clamp(0, widget.images.length - 1);
    _controller = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    if (widget.images.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = widget.size ??
            math.min(constraints.maxWidth, sizes.scheduleSliderSize);
        final radius = widget.borderRadius ?? sizes.radiusL;
        final background = widget.backgroundColor ?? AppColors.white;
        final indicatorPadding =
            widget.indicatorPadding ?? EdgeInsets.all(sizes.padXs);
        final indicatorTextStyle = widget.indicatorTextStyle ??
            AppTextStyles.caption(sizes).copyWith(color: AppColors.white);

        return SizedBox(
          width: side,
          height: side,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: DecoratedBox(
                  decoration: BoxDecoration(color: background),
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: widget.images.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return _SliderImage(
                        asset: widget.images[index],
                        fit: widget.fit,
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                right: sizes.padS,
                bottom: sizes.padS,
                child: Container(
                  padding: indicatorPadding,
                  decoration: BoxDecoration(
                    color: AppColors.blackAlpha60,
                    borderRadius: BorderRadius.circular(sizes.radiusM),
                  ),
                  child: Text(
                    '${_currentIndex + 1}/${widget.images.length}',
                    style: indicatorTextStyle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SliderImage extends StatelessWidget {
  final String asset;
  final BoxFit fit;

  const _SliderImage({
    required this.asset,
    required this.fit,
  });

  @override
  Widget build(BuildContext context) {
    final isSvg = asset.toLowerCase().endsWith('.svg');

    return Center(
      child: isSvg
          ? SvgPicture.asset(asset, fit: fit)
          : Image.asset(asset, fit: fit),
    );
  }
}
