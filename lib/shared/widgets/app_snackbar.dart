import 'package:flutter/material.dart';

/// Centralized helper for the app's transient feedback snackbars (toggle
/// confirmations, save/remove notices, errors).
///
/// Two things every call site needs, so they live here once instead of being
/// copy-pasted: a short duration (these are lightweight confirmations, not
/// alerts that need to linger), and clearing any snackbar that's currently
/// showing or queued before showing the new one — otherwise rapidly repeating
/// an action (e.g. toggling a switch on/off a few times) queues up a backlog
/// of stale messages that keep appearing long after the user moved on.
class AppSnackBar {
  const AppSnackBar._();

  static const Duration duration = Duration(milliseconds: 1500);

  /// Takes a [ScaffoldMessengerState] (not a [BuildContext]) so it works
  /// equally well from call sites that must capture the messenger before an
  /// `await` to avoid using a [BuildContext] across an async gap.
  static void show(ScaffoldMessengerState messenger, String message) {
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message), duration: duration));
  }
}
