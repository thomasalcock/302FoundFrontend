import 'package:http/http.dart' as http;
import 'package:threeotwo_found_frontend/models/user.dart';
import 'dart:convert';

class UserService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<User> fetchUserData(int id) async {
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
