import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:threeotwo_found_frontend/trustedPersons/trusted_persons_list_view.dart';
import 'package:threeotwo_found_frontend/account/account_view.dart';
import 'services/location_service.dart';

const notificationChannelId = 'my_foreground';
const int notificationId = 888;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  notificationChannelId,
  'MY FOREGROUND SERVICE',
  description: 'This channel is used for important notifications.',
  importance: Importance.low,
);

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Required to use plugins in the background isolate
  DartPluginRegistrant.ensureInitialized();

  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Start a LocationManager inside the background isolate so it attempts to
  // collect/send positions while the service runs.
  final lm = LocationManager();
  lm.start();

  // Keep the isolate alive with a periodic timer; the LocationManager itself
  // schedules its own work.
  Timer.periodic(const Duration(seconds: 60), (_) {
    // no-op; timer keeps isolate from exiting
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: notificationChannelId,
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: notificationId,
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

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
    await flutterLocalNotificationsPlugin.initialize(initSettings);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  } catch (e, st) {
    // Prevent plugin initialization failures from crashing the app on startup.
    debugPrint('flutter_local_notifications init failed: $e\n$st');
  }

  // Initialize background service (will spawn a background isolate).
  await initializeService();

  // Start app-level location manager for foreground behaviour.
  final lm = LocationManager();
  lm.start();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hessentag Fulda 2026',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: TrustedPersonsListView(),
      routes: {'/account': (context) => const AccountView()},
    );
  }
}
