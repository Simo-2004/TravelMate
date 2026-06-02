import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/core/theme/app_theme.dart';
import 'package:travelmate/features/navigation/navigation_shell.dart';
import 'package:travelmate/shared/state/personal_profile_store.dart';
import 'package:travelmate/shared/state/privacy_settings_store.dart';
import 'package:travelmate/shared/state/saved_trip_preview_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    SavedTripPreviewStore.instance.initialize(),
    PersonalProfileStore.instance.initialize(),
    PrivacySettingsStore.instance.initialize(),
  ]);
  runApp(const TravelMateApp());
}

class TravelMateApp extends StatelessWidget {
  const TravelMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const NavigationShell(),
    );
  }
}
