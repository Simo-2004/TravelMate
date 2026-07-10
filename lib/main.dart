import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/core/theme/app_theme.dart';
import 'package:travelmate/features/navigation/navigation_shell.dart';
import 'package:travelmate/shared/state/personal_profile_store.dart';
import 'package:travelmate/shared/state/privacy_settings_store.dart';
import 'package:travelmate/shared/state/saved_trip_preview_store.dart';

/// Initializes persistent stores and launches the TravelMate application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    SavedTripPreviewStore.instance.initialize(),
    PersonalProfileStore.instance.initialize(),
    PrivacySettingsStore.instance.initialize(),
  ]);
  runApp(const TravelMateApp());
}

/// Root widget that configures global theme and top-level navigation.
class TravelMateApp extends StatelessWidget {
  const TravelMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      builder: (context, child) {
        // Layout sizes are derived from screen dimensions (see AppSizes) on
        // the assumption of a roughly 1.0x text scale. Devices with a larger
        // default system font size would otherwise inflate text-driven
        // measurements (e.g. the bottom nav bar height) well beyond what the
        // rest of the proportional UI does, so the scale factor is clamped
        // to a reasonable range here.
        final mediaQuery = MediaQuery.of(context);
        final clampedScaler = mediaQuery.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.2,
        );

        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: clampedScaler),
          child: child!,
        );
      },
      home: const NavigationShell(),
    );
  }
}
