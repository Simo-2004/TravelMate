import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';

class SliderSection extends StatelessWidget {
  final String title;
  final Widget? child;
  final EdgeInsetsGeometry? padding;

  const SliderSection({
    super.key,
    required this.title,
    this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final resolvedPadding = padding ?? EdgeInsets.only(top: sizes.spaceM);

    return Padding(
      padding: resolvedPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleLg(sizes)),
          SizedBox(height: sizes.spaceS),
          child ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
