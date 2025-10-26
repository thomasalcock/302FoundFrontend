import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Handles app-level location logic: permissions, polling, and sending/saving.

/// Handles all location logic: permissions, polling, and retrieval.
class LocationManager {
  Timer? _timer;
  final Duration interval;
  final Function(Position position)? onPosition;
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
      'device_id': 'device_placeholder',
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
