import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';

import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
import 'package:travelmate/features/navigation/navigation_config.dart';
import 'package:travelmate/features/navigation/navigation_controller.dart';
import 'package:travelmate/shared/transitions/app_transitions.dart';

/// Main scaffold shell hosting app pages and the bottom navigation bar.
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

    final initialIndex = widget.config.initialIndex.clamp(0, _items.length - 1);

    _controller =
        widget.controller ?? NavigationController(initialIndex: initialIndex);
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
      return const Scaffold(body: SizedBox.shrink());
    }

    return NavigationScope(
      controller: _controller,
      items: _items,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final currentIndex = _controller.index.clamp(0, _items.length - 1);
          final currentItem = _items[currentIndex];
          final style = _style;
          final sizes = AppSizes.of(context);
          final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
          final indicatorSize = _calculateIndicatorSize(
            context,
            sizes: sizes,
            style: style,
            items: _items,
          );
          // Content-only height: BottomAppBar wraps its child in its own
          // SafeArea, which reserves the real bottom system inset *outside*
          // this box automatically. Baking that inset in here too would
          // double-reserve it and shrink the space actually available to
          // the row below what it needs.
          final barHeight = _calculateBarHeight(
            sizes: sizes,
            style: style,
            itemIndicatorSize: indicatorSize,
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
                    // BottomAppBar defaults to a 12px vertical / 16px
                    // horizontal padding in Material 3, on top of whatever
                    // we add ourselves below. Zeroing it out here keeps our
                    // own computed height (barHeight) accurate.
                    padding: EdgeInsets.zero,
                    height: barHeight,
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
                            indicatorSize: indicatorSize,
                            onTap: () => _controller.index = index,
                          );
                        }),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}

double _calculateBarHeight({
  required AppSizes sizes,
  required NavigationStyle style,
  required double itemIndicatorSize,
}) {
  final itemPadding = style.itemPadding(sizes);
  final padding = style.padding(sizes);
  final contentHeight = itemIndicatorSize + itemPadding.vertical;

  return contentHeight + padding.vertical;
}

/// Diameter of the circular icon+label badge, shared by every nav item so
/// they all render at a consistent size. It must fit the tallest stacked
/// icon+label content *and* the widest single-line label (e.g. "Settings"),
/// otherwise a label wraps to a second line and overflows the bar height
/// that was computed assuming a single line — which only shows up on
/// narrower screens where there's less slack between the two measurements.
double _calculateIndicatorSize(
  BuildContext context, {
  required AppSizes sizes,
  required NavigationStyle style,
  required List<NavigationItem> items,
}) {
  if (items.isEmpty) {
    return 0;
  }

  final labelStyle = style.labelStyle(sizes, true);
  final labelHeight = _maxLabelExtent(
    context,
    labelStyle,
    items,
    (size) => size.height,
  );
  final labelWidth = _maxLabelExtent(
    context,
    labelStyle,
    items,
    (size) => size.width,
  );
  final iconSize = style.iconSize(sizes);
  final indicatorPadding = style.indicatorPadding(sizes);
  final contentHeight = iconSize + style.labelSpacing(sizes) + labelHeight;
  final contentWidth = math.max(iconSize, labelWidth);

  return math.max(contentHeight, contentWidth) + (indicatorPadding * 2);
}

double _maxLabelExtent(
  BuildContext context,
  TextStyle style,
  List<NavigationItem> items,
  double Function(Size size) selectExtent,
) {
  final textScaler = MediaQuery.textScalerOf(context);
  final direction = Directionality.of(context);

  double maxExtent = 0;
  for (final item in items) {
    final painter = TextPainter(
      text: TextSpan(text: item.label, style: style),
      textDirection: direction,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();

    maxExtent = math.max(maxExtent, selectExtent(painter.size));
  }

  return maxExtent;
}

class _NavButton extends StatelessWidget {
  final NavigationItem item;
  final NavigationStyle style;
  final AppSizes sizes;
  final bool isSelected;
  final double indicatorSize;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.style,
    required this.sizes,
    required this.isSelected,
    required this.indicatorSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = style.iconColor(isSelected);
    final labelStyle = style.labelStyle(sizes, isSelected);
    final iconSize = style.iconSize(sizes);

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
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
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
