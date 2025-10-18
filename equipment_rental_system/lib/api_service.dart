import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:equipment_rental_system/login_page.dart';

class ApiService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  Future<Map<String, String>> _authHeaders({Map<String, String>? extra}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  // Store tokens
  Future<void> _setTokens({required String accessToken, String? refreshToken}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', accessToken);
    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken);
    }
  }

  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  Future<bool> _refreshAccessToken() async {
    try {
      final rt = await _getRefreshToken();
      if (rt == null) return false;
      final resp = await http.post(
        Uri.parse("$baseUrl/token/refresh"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': rt}),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final newAccess = data['token'] ?? data['accessToken'];
        if (newAccess is String && newAccess.isNotEmpty) {
          await _setTokens(accessToken: newAccess);
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<http.Response> _withAuthRetry(Future<http.Response> Function() requestFn) async {
    http.Response resp = await requestFn();
    if (resp.statusCode != 401) return resp;
    // Try refresh; only redirect if refresh fails too
    final refreshed = await _refreshAccessToken();
    if (!refreshed) {
      _redirectToLogin();
      return resp;
    }
    // Retry once with new access token
    resp = await requestFn();
    if (resp.statusCode == 401) {
      _redirectToLogin();
    }
    return resp;
  }

  void _redirectToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('refresh_token');
    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      Navigator.of(ctx).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  Future<Map<String, dynamic>> getUsers() async {
    try {
      final response = await _withAuthRetry(() async => http.get(Uri.parse("$baseUrl/users"), headers: await _authHeaders()));
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

      // Login returns tokens. Backward compatible with access-only tokens.
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['token'] ?? data['accessToken'];
        final refresh = data['refreshToken'] ?? data['refresh_token'];
        if (token is String) {
          await _setTokens(accessToken: token, refreshToken: refresh is String ? refresh : null);
        }
        return data;
      } else {
        final error = jsonDecode(response.body)['message'] ?? "Login failed";
        throw Exception(error);
      }
    } catch (e) {
      throw Exception("Unable to connect to server: $e");
    }
  }

  // Equipment APIs (aligned with backend /EquipmentList)
  Future<List<dynamic>> getEquipment() async {
    final resp = await _withAuthRetry(() async => http.get(
      Uri.parse("$baseUrl/EquipmentList/all"),
      headers: await _authHeaders(),
    ));
    if (resp.statusCode == 200) return jsonDecode(resp.body) as List<dynamic>;
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to fetch equipment');
  }

  Future<Map<String, dynamic>> createEquipment(Map<String, dynamic> data) async {
    final resp = await _withAuthRetry(() async => http.post(
      Uri.parse("$baseUrl/EquipmentList/create"),
      headers: await _authHeaders(),
      body: jsonEncode({
        'name': data['name'],
        'category': data['type'] ?? data['category'],
        'price': data['price'],
      }),
    ));
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      return (decoded['data'] ?? decoded) as Map<String, dynamic>;
    }
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to create equipment');
  }

  Future<Map<String, dynamic>> updateEquipment(String id, Map<String, dynamic> data) async {
    final resp = await _withAuthRetry(() async => http.put(
      Uri.parse("$baseUrl/EquipmentList/update/$id"),
      headers: await _authHeaders(),
      body: jsonEncode({
        if (data['name'] != null) 'name': data['name'],
        if (data['type'] != null) 'category': data['type'],
        if (data['price'] != null) 'price': data['price'],
      }),
    ));
    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      return (decoded['data'] ?? decoded) as Map<String, dynamic>;
    }
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to update equipment');
  }

  Future<void> deleteEquipment(String id) async {
    final resp = await _withAuthRetry(() async => http.delete(
      Uri.parse("$baseUrl/EquipmentList/delete/$id"),
      headers: await _authHeaders(),
    ));
    if (resp.statusCode != 200) {
      throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to delete equipment');
    }
  }

  Future<Map<String, dynamic>> requestEquipment({
    required String equipmentId,
    required num volume,
    required String rentalMethod, // e.g. 'hour' | 'meter'
  }) async {
    final resp = await _withAuthRetry(() async => http.post(
      Uri.parse("$baseUrl/EquipmentList/request/$equipmentId"),
      headers: await _authHeaders(),
      body: jsonEncode({
        'volume': volume,
        'Rentalmethod': rentalMethod,
      }),
    ));
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      return (decoded['data'] ?? decoded) as Map<String, dynamic>;
    }
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to request equipment');
  }

  Future<List<dynamic>> myEquipmentRequests() async {
    final resp = await _withAuthRetry(() async => http.get(
      Uri.parse("$baseUrl/EquipmentList/myRequests"),
      headers: await _authHeaders(),
    ));
    if (resp.statusCode == 200) return jsonDecode(resp.body) as List<dynamic>;
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to fetch my equipment requests');
  }

  // Maintenance requests actions
  Future<Map<String, dynamic>> approveMaintenance(String id, double price) async {
    final resp = await _withAuthRetry(() async => http.patch(
      Uri.parse("$baseUrl/MaintenanceRequest/approve/$id"),
      headers: await _authHeaders(),
      body: jsonEncode({"price": price}),
    ));
    if (resp.statusCode == 200) return jsonDecode(resp.body) as Map<String, dynamic>;
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to approve maintenance');
  }

  Future<void> rejectMaintenance(String id) async {
    final resp = await _withAuthRetry(() async => http.patch(
      Uri.parse("$baseUrl/MaintenanceRequest/reject/$id"),
      headers: await _authHeaders(),
    ));
    if (resp.statusCode != 204 && resp.statusCode != 200) {
      throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to reject maintenance');
    }
  }

  // Financial report endpoints
  Future<List<dynamic>> getUsersWithTransactions() async {
    final resp = await _withAuthRetry(() async => http.get(
      Uri.parse("$baseUrl/Transaction/GetUsersWithTransactions"),
      headers: await _authHeaders(),
    ));
    if (resp.statusCode == 200) return jsonDecode(resp.body) as List<dynamic>;
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to fetch users with transactions');
  }

  Future<List<dynamic>> getUserTransactionMonths(String userId) async {
    final resp = await _withAuthRetry(() async => http.get(
      Uri.parse("$baseUrl/Transaction/GetUserTransactionMonths/$userId"),
      headers: await _authHeaders(),
    ));
    if (resp.statusCode == 200) return jsonDecode(resp.body) as List<dynamic>;
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to fetch months');
  }

  Future<List<dynamic>> getTransactionsByMonth({
    required String userId,
    required int year,
    required int month,
  }) async {
    final resp = await _withAuthRetry(() async => http.get(
      Uri.parse("$baseUrl/Transaction/GetTransactionsByMonth/$userId/$year/$month"),
      headers: await _authHeaders(),
    ));
    if (resp.statusCode == 200) return jsonDecode(resp.body) as List<dynamic>;
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to fetch transactions');
  }

  // Global 401 handler
  void _handleUnauthorized(http.Response resp) async {
    if (resp.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        Navigator.of(ctx).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
      throw Exception('Unauthorized');
    }
  }

  // Maintenance APIs
  Future<Map<String, dynamic>> createMaintenanceRequest({required String name, required String message}) async {
    final resp = await _withAuthRetry(() async => http.post(
      Uri.parse("$baseUrl/MaintenanceRequest/SendRequest"),
      headers: await _authHeaders(),
      body: jsonEncode({ 'name': name, 'message': message }),
    ));
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to create maintenance request');
  }

  Future<List<dynamic>> listMaintenanceRequestsAdmin() async {
    final resp = await _withAuthRetry(() async => http.get(
      Uri.parse("$baseUrl/MaintenanceRequest/GetRequests"),
      headers: await _authHeaders(),
    ));
    if (resp.statusCode == 200) return jsonDecode(resp.body) as List<dynamic>;
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to fetch maintenance requests');
  }

  Future<List<dynamic>> myMaintenanceRequests() async {
    final resp = await _withAuthRetry(() async => http.get(
      Uri.parse("$baseUrl/MaintenanceRequest/myRequest"),
      headers: await _authHeaders(),
    ));
    if (resp.statusCode == 200) return jsonDecode(resp.body) as List<dynamic>;
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to fetch my maintenance requests');
  }

  Future<void> approveMaintenanceRequest(String id, num amount) async {
    final resp = await _withAuthRetry(() async => http.put(
      Uri.parse("$baseUrl/MaintenanceRequest/AcceptRequest/$id"),
      headers: await _authHeaders(),
      body: jsonEncode({ 'amount': amount }),
    ));
    if (resp.statusCode != 200) {
      throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to approve maintenance');
    }
  }

  Future<void> rejectMaintenanceRequest(String id) async {
    final resp = await _withAuthRetry(() async => http.put(
      Uri.parse("$baseUrl/MaintenanceRequest/RejectRequest/$id"),
      headers: await _authHeaders(),
    ));
    if (resp.statusCode != 200) {
      throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to reject maintenance');
    }
  }

  // Warehouse APIs
  Future<List<dynamic>> listWarehouseItems() async {
    final resp = await _withAuthRetry(() async => http.get(
      Uri.parse("$baseUrl/WarehouseManagement/getAll"),
      headers: await _authHeaders(),
    ));
    if (resp.statusCode == 200) return jsonDecode(resp.body) as List<dynamic>;
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to fetch warehouse items');
  }

  Future<Map<String, dynamic>> requestWarehouseItem({required String itemId, required int quantity}) async {
    final resp = await _withAuthRetry(() async => http.post(
      Uri.parse("$baseUrl/WarehouseManagement/request/$itemId"),
      headers: await _authHeaders(),
      body: jsonEncode({ 'quantityRequested': quantity }),
    ));
    if (resp.statusCode == 201 || resp.statusCode == 200) return jsonDecode(resp.body) as Map<String, dynamic>;
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to request warehouse item');
  }

  Future<List<dynamic>> listWarehouseRequestsAdmin() async {
    final resp = await _withAuthRetry(() async => http.post(
      Uri.parse("$baseUrl/WarehouseManagement/getRequests"),
      headers: await _authHeaders(),
      body: jsonEncode({}),
    ));
    if (resp.statusCode == 200) return jsonDecode(resp.body) as List<dynamic>;
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to fetch warehouse requests');
  }

  Future<List<dynamic>> myWarehouseRequests() async {
    final resp = await _withAuthRetry(() async => http.get(
      Uri.parse("$baseUrl/WarehouseManagement/getMyRequests"),
      headers: await _authHeaders(),
    ));
    if (resp.statusCode == 200) return jsonDecode(resp.body) as List<dynamic>;
    throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to fetch my warehouse requests');
  }

  Future<void> approveWarehouseRequest(String id) async {
    final resp = await _withAuthRetry(() async => http.put(
      Uri.parse("$baseUrl/WarehouseManagement/accept/$id"),
      headers: await _authHeaders(),
    ));
    if (resp.statusCode != 200) {
      throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to approve warehouse request');
    }
  }

  Future<void> rejectWarehouseRequest(String id) async {
    final resp = await _withAuthRetry(() async => http.put(
      Uri.parse("$baseUrl/WarehouseManagement/reject/$id"),
      headers: await _authHeaders(),
    ));
    if (resp.statusCode != 200) {
      throw Exception(jsonDecode(resp.body)['message'] ?? 'Failed to reject warehouse request');
    }
  }
}