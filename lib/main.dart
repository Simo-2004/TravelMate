import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/core/theme/app_theme.dart';
import 'package:travelmate/features/auth/login_screen.dart';
import 'package:travelmate/shared/state/auth_service.dart';
import 'package:travelmate/shared/state/chat_store.dart';
import 'package:travelmate/shared/state/personal_profile_store.dart';
import 'package:travelmate/shared/state/privacy_settings_store.dart';
import 'package:travelmate/shared/state/saved_trip_preview_store.dart';
import 'package:travelmate/shared/state/trip_store.dart';

/// Initializes persistent stores and launches the TravelMate application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    AuthService.instance.initialize(),
    TripStore.instance.initialize(),
    SavedTripPreviewStore.instance.initialize(),
    PersonalProfileStore.instance.initialize(),
    PrivacySettingsStore.instance.initialize(),
    ChatStore.instance.initialize(),
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
      home: const LoginScreen(),
    );
  }
}
