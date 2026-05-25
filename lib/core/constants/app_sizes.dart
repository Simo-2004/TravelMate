import 'package:flutter/material.dart';

class AppSizes {
  final double shortestSide;
  final double textScale;

  const AppSizes._(this.shortestSide, this.textScale);

  factory AppSizes.of(BuildContext context) {
    final media = MediaQuery.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(1.0);

    return AppSizes._(media.size.shortestSide, scale);
  }

  double _ratio(double factor) => shortestSide * factor;

  double get padXs => _ratio(0.012);
  double get padS => _ratio(0.022);
  double get padM => _ratio(0.032);
  double get padL => _ratio(0.06);

  double get spaceS => padM;
  double get spaceM => padL;
  double get spaceL => _ratio(0.088);

  double get radiusM => _ratio(0.032);
  double get radiusL => _ratio(0.06);
  double get iconM => _ratio(0.06);

  double get textSm => _ratio(0.032) * textScale;
  double get textMd => _ratio(0.042) * textScale;
  double get textLg => _ratio(0.06) * textScale;
  double get textHeightTight => 1.0 + (textScale - 1.0) * 0.2;

  double get buttonElevation => _ratio(0.005);
  double get navElevation => _ratio(0.02);

  double get sliderTileSize => _ratio(0.32);
  double get sliderTileSpacing => padS;
      double get sliderImageScale =>
        ((shortestSide / 700) * 1.2).clamp(0.6, 0.9).toDouble();
  double get scheduleSliderSize => _ratio(0.72);

  double get buttonH => padL;
  double get buttonV => _ratio(0.04);
}
