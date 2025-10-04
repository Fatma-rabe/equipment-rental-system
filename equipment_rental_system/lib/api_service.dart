import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
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

  // Equipment CRUD
  Future<List<dynamic>> getEquipment() async {
    final resp = await http.get(Uri.parse("$baseUrl/equipment"));
    if (resp.statusCode == 200) return jsonDecode(resp.body) as List<dynamic>;
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to fetch equipment');
  }

  Future<Map<String, dynamic>> createEquipment(Map<String, dynamic> data) async {
    final resp = await http.post(
      Uri.parse("$baseUrl/equipment"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to create equipment');
  }

  Future<Map<String, dynamic>> updateEquipment(String id, Map<String, dynamic> data) async {
    final resp = await http.put(
      Uri.parse("$baseUrl/equipment/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to update equipment');
  }

  Future<void> deleteEquipment(String id) async {
    final resp = await http.delete(Uri.parse("$baseUrl/equipment/$id"));
    if (resp.statusCode != 204 && resp.statusCode != 200) {
      throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to delete equipment');
    }
  }

  // Maintenance requests actions
  Future<Map<String, dynamic>> approveMaintenance(String id, double price) async {
    final resp = await http.patch(
      Uri.parse("$baseUrl/maintenance-requests/$id/approve"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"price": price}),
    );
    if (resp.statusCode == 200) return jsonDecode(resp.body) as Map<String, dynamic>;
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to approve maintenance');
  }

  Future<void> rejectMaintenance(String id) async {
    final resp = await http.patch(
      Uri.parse("$baseUrl/maintenance-requests/$id/reject"),
    );
    if (resp.statusCode != 204 && resp.statusCode != 200) {
      throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to reject maintenance');
    }
  }
}