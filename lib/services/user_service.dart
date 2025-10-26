import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:threeotwo_found_frontend/models/user.dart';
import 'dart:convert';

final environment = dotenv.get("ENVIRONMENT");
final apiUrl = environment == "production"
    ? dotenv.get("API_URL")
    : 'http://localhost:3000';

class UserService {
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

  static Future<User> createUser(User user) async {
    if (environment != "production") {
      return user;
    }

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_name': user.username,
          'full_name': user.fullname,
          'phone_number': user.phonenumber,
          'email': user.email,
          'alias': user.alias,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception(response.statusCode);
      }
      return User.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception('API-Error: $e');
    }
  }

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

  static Future<User> updateUserById(User user, int id) async {
    if (environment != "production") {
      return user;
    }

    try {
      final response = await http.put(
        Uri.parse('$apiUrl/user/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_name': user.username,
          'full_name': user.fullname,
          'phone_number': user.phonenumber,
          'email': user.email,
          'alias': user.alias,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(response.statusCode);
      }

      return User.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception('API-Error: $e');
    }
  }

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
