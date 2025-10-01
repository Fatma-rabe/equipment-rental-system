import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3000',
  );

  Future<Map<String, dynamic>> getUsers() async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/users"));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body)['message'] ?? "Failed to load users";
        throw Exception(error);
      }
    } catch (e) {
      throw Exception("Unable to connect to server: $e");
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http
          .post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body)['message'] ?? "Login failed";
        throw Exception(error);
      }
    } catch (e) {
      throw Exception("Unable to connect to server: $e");
    }
  }
}