import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:travelmate/core/theme/app_theme.dart';

/// Asset bundle that returns a tiny valid SVG for any key, so widgets calling
/// `SvgPicture.asset` render in tests without the real asset bundle.
class FakeAssetBundle extends CachingAssetBundle {
  static const String _svg =
      '<svg xmlns="http://www.w3.org/2000/svg" width="8" height="8"></svg>';

  @override
  Future<ByteData> load(String key) async {
    final bytes = Uint8List.fromList(utf8.encode(_svg));
    return ByteData.sublistView(bytes);
  }
}

/// Wraps [child] in a MaterialApp (with the app theme and a fake asset bundle)
/// so it can be pumped in isolation.
Widget wrapApp(Widget child) {
  return DefaultAssetBundle(
    bundle: FakeAssetBundle(),
    child: MaterialApp(theme: AppTheme.light(), home: child),
  );
}

/// Wraps [child] inside a Scaffold body — for widgets that expect Material
/// ancestors but do not provide their own Scaffold.
Widget wrapScaffold(Widget child) {
  return wrapApp(Scaffold(body: child));
}
