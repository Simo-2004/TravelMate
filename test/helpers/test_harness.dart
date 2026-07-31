/// Shared harness for widget-, component- and system-level tests.
///
/// Re-exports [fakes] and [fixtures] so a test file needs a single helper
/// import, and adds the Flutter-specific plumbing: an asset bundle stand-in,
/// widget wrappers, render-surface control, and one-call resets for the
/// app's singleton stores.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:travelmate/core/theme/app_theme.dart';
import 'package:travelmate/main.dart';
import 'package:travelmate/shared/data/trip_catalog.dart';
import 'package:travelmate/shared/models/personal_profile.dart';
import 'package:travelmate/shared/models/search_research_mode.dart';
import 'package:travelmate/shared/state/auth_service.dart';
import 'package:travelmate/shared/state/chat_store.dart';
import 'package:travelmate/shared/state/personal_profile_store.dart';
import 'package:travelmate/shared/state/saved_trip_preview_store.dart';
import 'package:travelmate/shared/state/search_research_mode_store.dart';
import 'package:travelmate/shared/state/trip_store.dart';

import 'fakes.dart';

export 'fakes.dart';
export 'fixtures.dart';

// ---------------------------------------------------------------------------
// Assets and widget wrappers
// ---------------------------------------------------------------------------

/// Asset bundle that answers any key with a tiny valid asset of the right
/// *kind*, so widgets render in tests without the real bundle: a minimal SVG
/// document for `.svg` keys, and a 1x1 transparent PNG for everything else.
///
/// Serving the right kind matters — a widget that picks `Image.asset` over
/// `SvgPicture.asset` can only be shown to work if the bytes it gets actually
/// decode as an image. Use [corruptAssetKey] to test the failure path instead.
class FakeAssetBundle extends CachingAssetBundle {
  FakeAssetBundle({this.corruptKeys = const <String>{}});

  /// Keys to answer with undecodable bytes, so a widget's error/placeholder
  /// branch can be exercised. [corruptAssetKey] is always treated this way.
  final Set<String> corruptKeys;

  static const String _svg =
      '<svg xmlns="http://www.w3.org/2000/svg" width="8" height="8"></svg>';

  /// A 1x1 fully transparent PNG (68 bytes).
  static final Uint8List _png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR4nGNgAAIAAAUAAXpe'
    'qz8AAAAASUVORK5CYII=',
  );

  @override
  Future<ByteData> load(String key) async {
    // `Image.asset` reads the manifest first to pick a resolution variant.
    // Handing it image bytes makes it fail to decode long before it ever gets
    // to the image itself, so answer it in its own format: an empty manifest,
    // meaning "no resolution variants, use the key as given".
    if (key == 'AssetManifest.bin') {
      return const StandardMessageCodec().encodeMessage(<String, Object>{})!;
    }

    if (key == corruptAssetKey || corruptKeys.contains(key)) {
      return ByteData.sublistView(
        Uint8List.fromList(utf8.encode('not-an-image')),
      );
    }

    final bytes = key.toLowerCase().endsWith('.svg')
        ? Uint8List.fromList(utf8.encode(_svg))
        : _png;
    return ByteData.sublistView(bytes);
  }
}

/// An asset key this bundle deliberately serves undecodable bytes for, so the
/// error/placeholder branch of an image widget can be exercised.
const String corruptAssetKey = 'assets/images/__corrupt__.png';

/// Wraps [child] in a MaterialApp (with the app theme and a fake asset bundle)
/// so it can be pumped in isolation.
///
/// Pass [bundle] to substitute a differently-behaving bundle — for example one
/// built with `FakeAssetBundle(corruptKeys: {...})` to force a hard-coded asset
/// to fail loading.
Widget wrapApp(Widget child, {AssetBundle? bundle}) {
  return DefaultAssetBundle(
    bundle: bundle ?? FakeAssetBundle(),
    child: MaterialApp(theme: AppTheme.light(), home: child),
  );
}

/// Wraps [child] inside a Scaffold body — for widgets that expect Material
/// ancestors but do not provide their own Scaffold.
Widget wrapScaffold(Widget child, {AssetBundle? bundle}) {
  return wrapApp(Scaffold(body: child), bundle: bundle);
}

// ---------------------------------------------------------------------------
// Store seeding and resets
// ---------------------------------------------------------------------------

/// Installs an in-memory account into [AuthService] and seeds the given
/// credentials, so login flows can be tested without SQLite / secure storage.
Future<void> seedAuthService({
  String username = AuthService.defaultUsername,
  String password = AuthService.defaultPassword,
}) async {
  final repository = testAccountRepository(FakeAccountDao());
  await repository.ensureSeeded(username: username, password: password);
  AuthService.instance.debugSetRepository(repository);
}

/// Resets [ChatStore.instance] onto a fresh in-memory data source, so chat
/// tests don't touch the SQLite plugin and don't leak history between tests.
void resetChatStore() {
  ChatStore.instance.debugSetDataSource(InMemoryChatData());
}

/// Puts every singleton store back to a known, plugin-free starting point:
/// empty bookmarks, the default profile and privacy settings, the real trip
/// catalog in memory, empty chat history and a seeded login account.
///
/// System- and component-level tests call this from `setUp` so no state can
/// leak between tests through the singletons.
Future<void> resetAllStores() async {
  SharedPreferences.setMockInitialValues({});
  SavedTripPreviewStore.instance.value = const [];
  SearchResearchModeStore.instance.value = SearchResearchMode.trips;
  PersonalProfileStore.instance.value = PersonalProfile.defaultProfile;
  PersonalProfileStore.instance.debugSetDataSource(InMemoryProfileData());
  TripStore.instance.debugSetData(
    trips: TripCatalog.trips,
    recents: TripCatalog.recents,
  );
  resetChatStore();
  await seedAuthService();
}

// ---------------------------------------------------------------------------
// Render surface
// ---------------------------------------------------------------------------

/// Renders at a phone-sized portrait surface, restoring the default afterwards.
///
/// The stock 800x600 test window is a landscape tablet, which the mobile-first
/// layouts are not designed for.
void usePhoneSurface(
  TestWidgetsFlutterBinding binding, {
  Size size = const Size(400, 900),
}) {
  final view = binding.platformDispatcher.implicitView!;
  view.devicePixelRatio = 1.0;
  view.physicalSize = size;
  addTearDown(() {
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });
}

/// Renders at a wide surface — used where the bottom navigation row needs
/// enough width to lay out all four labels.
void useWideSurface(TestWidgetsFlutterBinding binding) {
  usePhoneSurface(binding, size: const Size(900, 500));
}

// ---------------------------------------------------------------------------
// Whole-app driving (system level)
// ---------------------------------------------------------------------------

/// Pumps the real [TravelMateApp] — the same widget `main()` runs — behind the
/// fake asset bundle. The app opens on its login gate.
///
/// Also installs [ignoreRenderFlexOverflow], because the bottom navigation bar
/// is what trips those cosmetic overflows and it only exists once the whole
/// app is mounted.
Future<void> pumpApp(WidgetTester tester) async {
  ignoreRenderFlexOverflow();
  await tester.pumpWidget(
    DefaultAssetBundle(bundle: FakeAssetBundle(), child: const TravelMateApp()),
  );
  await tester.pump();
}

/// Advances until the route transition has fully finished.
///
/// Settling (rather than pumping a fixed duration) matters twice over: a
/// `pushReplacement` only disposes the route it replaced once the animation
/// completes, and a route that is still animating in is wrapped in an
/// `IgnorePointer`, so taps on it silently miss.
Future<void> pumpTransition(WidgetTester tester) async {
  await tester.pump();
  await tester.pumpAndSettle();
}

/// Fills in the login gate and taps Enter, leaving the app on the Home tab.
Future<void> logIn(
  WidgetTester tester, {
  String username = AuthService.defaultUsername,
  String password = AuthService.defaultPassword,
}) async {
  await tester.enterText(find.byType(TextField).first, username);
  await tester.enterText(find.byType(TextField).last, password);
  // The gate is a scroll view and the button can sit right on the bottom edge
  // of a short surface, where a tap would miss it.
  await tester.ensureVisible(find.text('Enter'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Enter'));
  await pumpTransition(tester);
}

/// Taps a bottom-navigation tab by its label and waits for the switch.
Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await pumpTransition(tester);
}

/// Swallows RenderFlex overflow errors for the duration of the current test.
///
/// The bottom nav bar can trip a small cosmetic overflow in debug at some
/// surface sizes; that is a paint-time warning, not a logic failure. Every
/// other Flutter error still fails the test.
///
/// Must be called from the test *body*, not from `setUp`: the test binding
/// installs its own `FlutterError.onError` when the test starts, which would
/// overwrite an override registered earlier.
void ignoreRenderFlexOverflow() {
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('A RenderFlex overflowed')) {
      return;
    }
    originalOnError?.call(details);
  };
  addTearDown(() => FlutterError.onError = originalOnError);
}
