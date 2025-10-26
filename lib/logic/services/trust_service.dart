import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:threeotwo_found_frontend/logic/models/trust.dart';
import 'dart:convert';

final environment = kDebugMode ? 'development' : 'production';
final apiUrl = environment == 'production'
    ? const String.fromEnvironment('API_URL', defaultValue: '')
    : 'http://localhost:3000';

class TrustService {
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
