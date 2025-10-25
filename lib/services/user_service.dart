import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:threeotwo_found_frontend/models/user.dart';
import 'dart:convert';

final environment = dotenv.get("ENVIRONMENT");

class UserService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<User> fetchUserData(int id) async {
    if (environment == "test") {
      return User(
        id: id,
        auth_token: "hjsfjklhfjshf",
        user_name: "Max.Mustermann",
        full_name: "Max Mustermann",
        phone_number: "phone_number",
        email: "email",
        alias: 234234,
      );
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/user/read/$id'));

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Fehler: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API-Fehler: $e');
    }
  }
}
