import 'package:flutter/material.dart';

import 'package:travelmate/features/navigation/navigation_config.dart';

class NavigationController extends ChangeNotifier {
  NavigationController({int initialIndex = 0}) : _index = initialIndex;

  int _index;
  int _focusRequest = 0;
  int _consumedFocusRequest = 0;

  int get index => _index;
  int get focusRequest => _focusRequest;

  set index(int value) {
    if (value == _index) {
      return;
    }
    _index = value;
    notifyListeners();
  }

  void requestFocus() {
    _focusRequest += 1;
    notifyListeners();
  }

  /// Returns true once per pending [requestFocus] call, regardless of how
  /// many pages have listened to (and been recreated by) this controller.
  bool consumeFocusRequest() {
    if (_focusRequest == _consumedFocusRequest) {
      return false;
    }
    _consumedFocusRequest = _focusRequest;
    return true;
  }
}

class NavigationScope extends InheritedNotifier<NavigationController> {
  final List<NavigationItem> items;

  const NavigationScope({
    super.key,
    required NavigationController controller,
    required this.items,
    required Widget child,
  }) : super(notifier: controller, child: child);

  static NavigationScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NavigationScope>();
  }

  static NavigationController? maybeControllerOf(BuildContext context) {
    return maybeOf(context)?.notifier;
  }

  static int? indexOfLabel(BuildContext context, String label) {
    final scope = maybeOf(context);
    if (scope == null) {
      return null;
    }

    final index = scope.items.indexWhere((item) => item.label == label);
    return index == -1 ? null : index;
  }
}
