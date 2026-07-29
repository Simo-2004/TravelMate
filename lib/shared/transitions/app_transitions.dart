import 'package:flutter/material.dart';

class AppTransitions {
  static const Duration pageSwitchDuration = Duration(milliseconds: 260);
  static const Duration pageSwitchReverseDuration = Duration(milliseconds: 200);

  static Widget switcherTransition(Widget child, Animation<double> animation) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final offset = Tween<Offset>(
      begin: const Offset(0.02, 0.0),
      end: Offset.zero,
    ).animate(curved);

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(position: offset, child: child),
    );
  }

  static Widget switcherLayout(
    Widget? currentChild,
    List<Widget> previousChildren,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [...previousChildren, ?currentChild],
    );
  }
}
