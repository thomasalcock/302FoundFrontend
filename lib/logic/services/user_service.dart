/// 302FoundFrontend (2025) - Service: User API helpers.
///
/// Centralized HTTP helpers and development stubs for current user and user
/// CRUD operations. Methods return stubbed values when not running in
/// production to keep the UI responsive during local development.
///
/// Example:
/// ```dart
/// final current = await UserService.getCurrentUser();
/// ```
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:threeotwo_found_frontend/logic/models/user.dart';
import 'dart:convert';

final environment = kDebugMode ? 'development' : 'production';
final apiUrl = environment == 'production'
    ? const String.fromEnvironment('API_URL', defaultValue: '')
    : 'http://localhost:3000';

/// UserService contains static helpers for user-related backend operations.
///
/// All methods may throw an [Exception] on non-success HTTP responses.
class UserService {
  /// Retrieve the currently authenticated user (development: stub).
  /// @return Future<User>
  static User? loggedInUser;

  static Future<User> login(String username, String password) async {
    if (loggedInUser != null) return loggedInUser!;

    if (environment != "production") {
      final mock = User(
        id: 1,
        username: username.isNotEmpty ? username : "dev_user",
        fullname: "Dev User",
        phonenumber: "+000000000",
        email: "$username@local.dev",
        alias: 9999,
      );
      loggedInUser = mock;
      return mock;
    }

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode != 200) {
        throw Exception('Login failed: ${response.statusCode}');
      }

      final user = User.fromJson(jsonDecode(response.body));
      loggedInUser = user;
      return user;
    } catch (e) {
      throw Exception('API-Error: $e');
    }
  }

  static Future<User> getCurrentUser() async {
    if (loggedInUser != null) {
      return loggedInUser!;
    }

    if (environment != "production") {
      return User(
        id: 1,
        username: "max_mustermann",
        fullname: "Max Mustermann",
        phonenumber: "+123456789",
        email: "max@mustermann.de",
        alias: 1001,
      );
    }

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/user/current'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(response.statusCode);
      }

      return User.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception('API-Error: $e');
    }
  }

  /// Create a new user via the API.
  /// @param user model to create
  /// @return Future<User> created user returned by backend
  static Future<User> createUser(User user) async {
    if (environment != "production") {
      return user;
    }

    try {
      final bodyMap = user.toJson();
      bodyMap.remove('id');
      final response = await http.post(
        Uri.parse('$apiUrl/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyMap),
      );

      if (response.statusCode != 201) {
        throw Exception(response.statusCode);
      }
      return User.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception('API-Error: $e');
    }
  }

  /// Get a user by id.
  /// @param id user id
  /// @return Future<User>
  static Future<User> getUserById(int id) async {
    if (environment != "production") {
      return User(
        id: id,
        username: "max_mustermann",
        fullname: "Max Mustermann",
        phonenumber: "+123",
        email: "email@domain.com",
        alias: 123,
      );
    }

    try {
      final response = await http.get(Uri.parse('$apiUrl/user/$id'));

      if (response.statusCode != 200) {
        throw Exception(response.statusCode);
      }

      return User.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception('API-ERROR: $e');
    }
  }

  /// Update a user by id.
  /// @param user updated user model
  /// @param id id of user to update
  /// @return Future<User> updated model from API
  static Future<User> updateUserById(User user, int id) async {
    if (environment != "production") {
      return user;
    }

    try {
      final bodyMap = user.toJson();
      bodyMap.remove('id');
      final response = await http.put(
        Uri.parse('$apiUrl/user/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyMap),
      );

      if (response.statusCode != 200) {
        throw Exception(response.statusCode);
      }

      return User.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception('API-Error: $e');
    }
  }

  /// Delete a user by id.
  /// @param id id of user to delete
  /// @return Future<void>
  static Future<void> deleteUserById(int id) async {
    if (environment != "production") {
      return;
    }

    try {
      final response = await http.delete(Uri.parse('$apiUrl/user/delete/$id'));

      if (response.statusCode != 204) {
        throw Exception(response.statusCode);
      }
    } catch (e) {
      throw Exception('API-Error: $e');
    }
  }
}
