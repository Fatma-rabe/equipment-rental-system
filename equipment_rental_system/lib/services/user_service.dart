import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  Future<List<Map<String, dynamic>>> listUsers() async {
    final resp = await http.get(Uri.parse('$baseUrl/users'));
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      if (body is List) return body.cast<Map<String, dynamic>>();
      if (body is Map && body['users'] is List) {
        return (body['users'] as List).cast<Map<String, dynamic>>();
      }
      throw Exception('Unexpected users payload');
    }
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to fetch users');
  }

  Future<Map<String, dynamic>> createUser({
    required String email,
    required String password,
    String? name,
    String role = 'user',
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'email': email,
        'password': password,
        if (name != null) 'name': name,
        'role': role,
      }),
    );
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to create user');
  }

  Future<Map<String, dynamic>> updateUser(String id, Map<String, dynamic> data) async {
    final resp = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to update user');
  }

  Future<void> deleteUser(String id) async {
    final resp = await http.delete(Uri.parse('$baseUrl/users/$id'));
    if (resp.statusCode != 204 && resp.statusCode != 200) {
      throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to delete user');
    }
  }
}
