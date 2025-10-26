/// 302FoundFrontend (2025) - Service for Trust (trusted persons) API access.
///
/// Provides simple CRUD helpers used by the UI to read and modify trust
/// relationships. In development mode these methods return local stub data.
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:threeotwo_found_frontend/logic/models/trust.dart';
import 'dart:convert';

final environment = kDebugMode ? 'development' : 'production';
final apiUrl = environment == 'production'
    ? const String.fromEnvironment('API_URL', defaultValue: '')
    : 'http://localhost:3000';

/// TrustService contains static helpers for backend operations.
///
/// Methods may throw an [Exception] on non-success HTTP responses.
/// Example usage:
/// ```dart
/// final trusts = await TrustService.getTrustsByUserId(currentUserId);
/// ```
class TrustService {
  /// Retrieve all trusts (development: stubbed list).
  /// @return Future<List<Trust>>
  static Future<List<Trust>> getAllTrusts() async {
    if (environment != "production") {
      return [
        Trust(id: 1, userId: 1, trusteeId: 2),
        Trust(id: 2, userId: 1, trusteeId: 3),
      ];
    }

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/trust'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(response.statusCode);
      }

      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Trust.fromJson(e)).toList();
    } catch (e) {
      throw Exception('API-Error: $e');
    }
  }

  /// Get trusts for a specific user.
  /// @param userId id of the user whose trusts to retrieve.
  /// @return Future<List<Trust>>
  static Future<List<Trust>> getTrustsByUserId(int userId) async {
    if (environment != "production") {
      return [Trust(id: 1, userId: userId, trusteeId: 2)];
    }

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/trust/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) throw Exception(response.statusCode);

      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Trust.fromJson(e)).toList();
    } catch (e) {
      throw Exception('API-Error: $e');
    }
  }

  /// Create a new trust relationship.
  /// @param trust Trust model to create.
  /// @return Future<Trust> created object from API.
  static Future<Trust> createTrust(Trust trust) async {
    if (environment != "production") {
      return trust;
    }

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/trust'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': trust.userId,
          'trustee_id': trust.trusteeId,
        }),
      );

      if (response.statusCode != 201) throw Exception(response.statusCode);

      return Trust.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception('API-Error: $e');
    }
  }

  /// Retrieve a trust by its id.
  /// @param id Trust id
  /// @return Future<Trust>
  static Future<Trust> getTrustById(int id) async {
    if (environment != "production") {
      return Trust(id: id, userId: 1, trusteeId: 2);
    }

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/trust/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) throw Exception(response.statusCode);

      return Trust.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception('API-Error: $e');
    }
  }

  /// Update a trust by id.
  /// @param trust updated trust model
  /// @param id id of trust to update
  /// @return Future<Trust> updated model from API
  static Future<Trust> updateTrustById(Trust trust, int id) async {
    if (environment != "production") {
      return trust;
    }

    try {
      final response = await http.put(
        Uri.parse('$apiUrl/trust/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': trust.userId,
          'trustee_id': trust.trusteeId,
        }),
      );

      if (response.statusCode != 200) throw Exception(response.statusCode);

      return Trust.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception('API-Error: $e');
    }
  }

  /// Delete a trust by id.
  /// @param id id of trust to delete
  /// @return Future<void>
  static Future<void> deleteTrustById(int id) async {
    if (environment != "production") {
      return;
    }

    try {
      final response = await http.delete(Uri.parse('$apiUrl/trust/delete/$id'));

      if (response.statusCode != 204) throw Exception(response.statusCode);
    } catch (e) {
      throw Exception('API-Error: $e');
    }
  }
}
