import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';

import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
import 'package:travelmate/features/navigation/navigation_config.dart';
import 'package:travelmate/features/navigation/navigation_controller.dart';
import 'package:travelmate/shared/transitions/app_transitions.dart';

class NavigationShell extends StatefulWidget {
  final NavigationConfig config;
  final NavigationController? controller;

  const NavigationShell({
    super.key,
    this.config = NavigationDefaults.config,
    this.controller,
  });

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  late final NavigationController _controller;
  late final bool _ownsController;

  List<NavigationItem> get _items => widget.config.items;
  NavigationStyle get _style => widget.config.style;

  @override
  void initState() {
    super.initState();
    if (_items.isEmpty) {
      _controller = widget.controller ?? NavigationController();
      _ownsController = widget.controller == null;
      return;
    }

    final initialIndex =
        widget.config.initialIndex.clamp(0, _items.length - 1);

    _controller = widget.controller ??
        NavigationController(initialIndex: initialIndex as int);
    _ownsController = widget.controller == null;
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return const Scaffold(
        body: SizedBox.shrink(),
      );
    }

    return NavigationScope(
      controller: _controller,
      items: _items,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final currentIndex =
              _controller.index.clamp(0, _items.length - 1) as int;
          final currentItem = _items[currentIndex];
          final style = _style;
          final sizes = AppSizes.of(context);
          final isKeyboardOpen =
              MediaQuery.of(context).viewInsets.bottom > 0;
          final barHeight = _calculateBarHeight(
            context,
            sizes: sizes,
            style: style,
            items: _items,
          );

          return Scaffold(
            appBar: AppBar(
              title: Text(
                currentItem.title,
                style: AppTextStyles.titleLg(sizes),
              ),
            ),
            body: AnimatedSwitcher(
              duration: AppTransitions.pageSwitchDuration,
              reverseDuration: AppTransitions.pageSwitchReverseDuration,
              transitionBuilder: AppTransitions.switcherTransition,
              layoutBuilder: AppTransitions.switcherLayout,
              child: KeyedSubtree(
                key: ValueKey<int>(currentIndex),
                child: _items[currentIndex].page,
              ),
            ),
            bottomNavigationBar: isKeyboardOpen
                ? null
                : BottomAppBar(
                    color: style.backgroundColor,
                    elevation: style.elevation(sizes),
                    height: barHeight,
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: style.padding(sizes),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(_items.length, (index) {
                            final item = _items[index];
                            final isSelected = index == currentIndex;

                            return _NavButton(
                              item: item,
                              style: style,
                              sizes: sizes,
                              isSelected: isSelected,
                              onTap: () => _controller.index = index,
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}

double _calculateBarHeight(
  BuildContext context, {
  required AppSizes sizes,
  required NavigationStyle style,
  required List<NavigationItem> items,
}) {
  if (items.isEmpty) {
    return 0;
  }

  final padding = style.padding(sizes);
  final itemPadding = style.itemPadding(sizes);
  final labelStyle = style.labelStyle(sizes, true);
  final labelHeight = _maxLabelHeight(context, labelStyle, items);
  final iconSize = style.iconSize(sizes);
  final indicatorPadding = style.indicatorPadding(sizes);
  final indicatorContentHeight =
      iconSize + style.labelSpacing(sizes) + labelHeight;
  final indicatorSize = indicatorContentHeight + (indicatorPadding * 2);
  final contentHeight = indicatorSize + itemPadding.vertical;
  final safeBottom = MediaQuery.of(context).padding.bottom;

  return contentHeight + padding.vertical + safeBottom;
}

double _maxLabelHeight(
  BuildContext context,
  TextStyle style,
  List<NavigationItem> items,
) {
  final textScaler = MediaQuery.textScalerOf(context);
  final direction = Directionality.of(context);

  double maxHeight = 0;
  for (final item in items) {
    final painter = TextPainter(
      text: TextSpan(text: item.label, style: style),
      textDirection: direction,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();

    maxHeight = math.max(maxHeight, painter.size.height);
  }

  return maxHeight;
}

class _NavButton extends StatelessWidget {
  final NavigationItem item;
  final NavigationStyle style;
  final AppSizes sizes;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.style,
    required this.sizes,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = style.iconColor(isSelected);
    final labelStyle = style.labelStyle(sizes, isSelected);
    final iconSize = style.iconSize(sizes);
    final indicatorPadding = style.indicatorPadding(sizes);
    final labelHeight = _labelHeight(context, labelStyle, item.label);
    final indicatorContentHeight =
        iconSize + style.labelSpacing(sizes) + labelHeight;
    final indicatorSize = indicatorContentHeight + (indicatorPadding * 2);

    final Widget iconWidget;
    if (item.svgAsset != null) {
      iconWidget = SvgPicture.asset(
        item.svgAsset!,
        width: iconSize,
        height: iconSize,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      );
    } else {
      iconWidget = Icon(item.icon, color: iconColor, size: iconSize);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: style.itemRadius(sizes),
      child: Padding(
        padding: style.itemPadding(sizes),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: indicatorSize,
              height: indicatorSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? style.selectedIndicatorColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconWidget,
                  SizedBox(height: style.labelSpacing(sizes)),
                  Text(
                    item.label,
                    style: labelStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

double _labelHeight(
  BuildContext context,
  TextStyle style,
  String label,
) {
  final textScaler = MediaQuery.textScalerOf(context);
  final direction = Directionality.of(context);

  final painter = TextPainter(
    text: TextSpan(text: label, style: style),
    textDirection: direction,
    textScaler: textScaler,
    maxLines: 1,
  )..layout();

  return painter.size.height;
}
