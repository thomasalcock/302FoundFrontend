import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:threeotwo_found_frontend/logic/models/location.dart';
import 'dart:convert';

final environment = kDebugMode ? 'development' : 'production';
final apiUrl = environment == 'production'
    ? const String.fromEnvironment('API_URL', defaultValue: '')
    : 'http://localhost:3000';

class LocationService {
  static Future<List<Location>> getAllLocations() async {
    if (environment != "production") {
      return [
        Location(id: 1, userId: 1, latitude: 5200000, longitude: 130000),
        Location(id: 2, userId: 2, latitude: 4800000, longitude: 110000),
      ];
    }

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/location'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(response.statusCode);
      }

      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Location.fromJson(e)).toList();
    } catch (e) {
      throw Exception('API-Error: $e');
    }
  }

  static Future<List<Location>> getLocationsByUserId(int userId) async {
    if (environment != "production") {
      return [
        Location(id: 1, userId: userId, latitude: 5200000, longitude: 130000),
      ];
    }

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/location/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(response.statusCode);
      }

      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Location.fromJson(e)).toList();
    } catch (e) {
      throw Exception('API-Error: $e');
    }
  }

  static Future<Location> createLocation(Location location) async {
    if (environment != "production") {
      return location;
    }

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/location'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': location.userId,
          'latitude': location.latitude,
          'longitude': location.longitude,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception(response.statusCode);
      }

      return Location.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception('API-Error: $e');
    }
  }

  static Future<Location> getLocationById(int id) async {
    if (environment != "production") {
      return Location(id: id, userId: 1, latitude: 5200000, longitude: 130000);
    }

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/location/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(response.statusCode);
      }

      return Location.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception('API-Error: $e');
    }
  }

  static Future<Location> updateLocationById(Location location, int id) async {
    if (environment != "production") {
      return location;
    }

    try {
      final response = await http.put(
        Uri.parse('$apiUrl/location/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': location.userId,
          'latitude': location.latitude,
          'longitude': location.longitude,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(response.statusCode);
      }

      return Location.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception('API-Error: $e');
    }
  }

  static Future<void> deleteLocationById(int id) async {
    if (environment != "production") {
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/location/delete/$id'),
      );

      if (response.statusCode != 204) {
        throw Exception(response.statusCode);
      }
    } catch (e) {
      throw Exception('API-Error: $e');
    }
  }

  static Future<bool> uploadPayload(
    Map<String, dynamic> payload, {
    String? apiToken,
  }) async {
    if (environment != "production") {
      // In development mode treat as successful upload so handler can clear queue locally.
      return true;
    }

    try {
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (apiToken != null && apiToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiToken';
      }

      final resp = await http
          .post(
            Uri.parse('$apiUrl/location'),
            headers: headers,
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 12));

      return resp.statusCode >= 200 && resp.statusCode < 300;
    } catch (e) {
      return false;
    }
  }
}
