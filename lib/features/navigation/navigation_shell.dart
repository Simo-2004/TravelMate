import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:travelmate/features/navigation/navigation_config.dart';

class NavigationShell extends StatefulWidget {
  final NavigationConfig config;

  const NavigationShell({
    super.key,
    this.config = NavigationDefaults.config,
  });

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  late int _currentIndex;

  List<NavigationItem> get _items => widget.config.items;
  NavigationStyle get _style => widget.config.style;

  @override
  void initState() {
    super.initState();
    if (_items.isEmpty) {
      _currentIndex = 0;
      return;
    }

    _currentIndex =
        widget.config.initialIndex.clamp(0, _items.length - 1) as int;
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return const Scaffold(
        body: SizedBox.shrink(),
      );
    }

    final currentItem = _items[_currentIndex];
    final style = _style;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentItem.title),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _items.map((item) => item.page).toList(),
      ),
      bottomNavigationBar: BottomAppBar(
        color: style.backgroundColor,
        elevation: style.elevation,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: style.padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final isSelected = index == _currentIndex;

                return _NavButton(
                  item: item,
                  style: style,
                  isSelected: isSelected,
                  onTap: () => setState(() => _currentIndex = index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final NavigationItem item;
  final NavigationStyle style;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.style,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = style.iconColor(isSelected);
    final labelStyle = style.labelStyle(isSelected);

    final Widget iconWidget;
    if (item.svgAsset != null) {
      iconWidget = SvgPicture.asset(
        item.svgAsset!,
        width: style.iconSize,
        height: style.iconSize,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      );
    } else {
      iconWidget = Icon(item.icon, color: iconColor, size: style.iconSize);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: style.itemRadius,
      child: Padding(
        padding: style.itemPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            SizedBox(height: style.labelSpacing),
            Text(
              item.label,
              style: labelStyle,
            ),
          ],
        ),
      ),
    );
  }
}
