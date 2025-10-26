// 302FoundFrontend (2025) - App entry: initializes background service, notifications, and starts the Flutter UI.
import 'dart:async';

import 'package:threeotwo_found_frontend/gui/account/login.dart';
import 'package:threeotwo_found_frontend/logic/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:threeotwo_found_frontend/gui/trustedPersons/trusted_persons_list_view.dart';
import 'package:threeotwo_found_frontend/gui/account/account_view.dart';
import 'logic/handler/location_handler.dart' as location_handler;

@pragma('vm:entry-point')
/// Background service entry-point used by flutter_background_service.
///
/// Starts the location handler inside the background isolate.
/// @param service The [ServiceInstance] provided by the plugin.
/// @return void
///
/// Example:
/// ```dart
/// // Called by native/plugin when background isolate is created.
/// onStart(service);
/// ```
void onStart(ServiceInstance service) => location_handler.onStart(service);

@pragma('vm:entry-point')
/// iOS background callback required by the background service plugin.
///
/// This forwards the call to the location handler which performs any iOS-specific
/// background setup. Returns `true` on success.
/// @param service The [ServiceInstance] provided by the plugin.
/// @return Future<bool> indicating whether iOS background init succeeded.
///
/// Example:
/// ```dart
/// await onIosBackground(service);
/// ```
Future<bool> onIosBackground(ServiceInstance service) =>
    location_handler.onIosBackground(service);

/// Application entry point: prepares plugins and starts background/foreground layers.
///
/// This function initializes local notifications and the background service,
/// then starts a foreground LocationManager and runs the Flutter app.
/// Example initialization sequence:
/// ```dart
/// await main();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // dotenv removed; use kDebugMode / build-time config instead.

  // Initialize flutter_local_notifications and create channel BEFORE starting background service.
  try {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('ic_launcher');
    final InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );
    await location_handler.flutterLocalNotificationsPlugin.initialize(
      initSettings,
    );
    await location_handler.flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          location_handler.locationNotificationChannel,
        );
  } catch (e, st) {
    // Prevent plugin initialization failures from crashing the app on startup.
    debugPrint('flutter_local_notifications init failed: $e\n$st');
  }

  // Initialize background service (will spawn a background isolate).
  await location_handler.initializeService(
    onStartCallback: onStart,
    onIosBackgroundCallback: onIosBackground,
  );

  // Start app-level location manager for foreground behaviour.
  final lm = location_handler.LocationManager();
  lm.start();

  runApp(const MyApp());
}

/// Root widget for the application.
///
/// Minimal [StatelessWidget] that configures the app theme and navigation.
/// Example:
/// ```dart
/// runApp(const MyApp());
/// ```
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hessentag Fulda 2026',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: UserService.loggedInUser != null
          ? const TrustedPersonsListView()
          : const Login(),
      routes: {'/account': (context) => const AccountView()},
    );
  }
}
