import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Combined handler: background service callbacks and LocationManager.

const String locationNotificationChannelId = 'location_service_channel';
const int notificationIdLocation = 888;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel locationNotificationChannel =
    AndroidNotificationChannel(
      locationNotificationChannelId,
      'Schutzengel Service',
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
      ?.createNotificationChannel(locationNotificationChannel);

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

Future<void> initializeService({
  required void Function(ServiceInstance) onStartCallback,
  required Future<bool> Function(ServiceInstance) onIosBackgroundCallback,
}) async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStartCallback,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: locationNotificationChannelId,
      initialNotificationTitle: 'Schutzengel',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: notificationIdLocation,
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStartCallback,
      onBackground: onIosBackgroundCallback,
    ),
  );
}

/// Handles all location logic: permissions, polling, and retrieval.
class LocationManager {
  Timer? _timer;
  final Duration interval;
  final Function(Position position)? onPosition;
  final String deviceId;
  bool _isRunning = false;

  // Environment / API config
  final String _environment = kDebugMode ? 'development' : 'production';
  late final String _apiUrl = _environment == 'production'
      ? const String.fromEnvironment('API_URL', defaultValue: '')
      : 'http://localhost:3000';
  final String _apiToken = const String.fromEnvironment(
    'API_TOKEN',
    defaultValue: '',
  );

  LocationManager({
    this.interval = const Duration(seconds: 60),
    this.onPosition,
    this.deviceId = 'device_placeholder',
  });

  /// Start periodic location updates.
  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(interval, (_) async {
      try {
        final position = await _determinePosition();
        onPosition?.call(position);
        await _handlePosition(position);
      } catch (e) {
        // You might log or report the error.
      }
    });
  }

  /// Stop periodic location updates.
  void stop() {
    _timer?.cancel();
    _isRunning = false;
  }

  /// Get the current position once.
  Future<Position> getCurrentPosition() async {
    return _determinePosition();
  }

  /// Internal: handles permissions and returns the current position.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, cannot request.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _handlePosition(Position pos) async {
    final payload = {
      'device_id': deviceId,
      'loc': {
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'accuracy': pos.accuracy,
        'timestamp': pos.timestamp.toUtc().toIso8601String(),
      },
    };

    if (_environment != 'production') {
      // Save locally in SharedPreferences queue
      final prefs = await SharedPreferences.getInstance();
      final queue = prefs.getStringList('bg_loc_queue') ?? <String>[];
      queue.add(jsonEncode(payload));
      await prefs.setStringList('bg_loc_queue', queue);
      return;
    }

    // Production: send to API, include token if provided
    try {
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (_apiToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $_apiToken';
      }

      final resp = await http
          .post(
            Uri.parse('$_apiUrl/location'),
            headers: headers,
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 12));

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        // on failure, persist locally for retry
        final prefs = await SharedPreferences.getInstance();
        final queue = prefs.getStringList('bg_loc_queue') ?? <String>[];
        queue.add(jsonEncode(payload));
        await prefs.setStringList('bg_loc_queue', queue);
      }
    } catch (e) {
      // network or timeout -> persist locally
      final prefs = await SharedPreferences.getInstance();
      final queue = prefs.getStringList('bg_loc_queue') ?? <String>[];
      queue.add(jsonEncode(payload));
      await prefs.setStringList('bg_loc_queue', queue);
    }
  }

  /// Dispose resources when no longer needed.
  void dispose() {
    stop();
  }
}
