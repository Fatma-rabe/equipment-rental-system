import 'dart:convert';
import 'package:equipment_rental_system/pages/UserDashboardPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'admin_dashboard.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> handleLogin() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = "يرجى إدخال البريد الإلكتروني وكلمة المرور";
      });
      return;
    }

    try {
      final response = await http
          .post(
        Uri.parse('http://10.83.126.161:3000/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      )
          .timeout(const Duration(seconds: 73));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final token = decoded['token'];

        if (token == null) {
          setState(() {
            errorMessage = decoded['message']?.toString() ??
                "فشل تسجيل الدخول: لا يوجد توكن";
          });
          return;
        }


        Map<String, dynamic> payload = Jwt.parseJwt(token);
        String role = payload['role']?.toLowerCase() ?? 'user';

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserDashboardPage()),
          );
        }
      } else {
        String backendMsg = '';
        try {
          final m = jsonDecode(response.body);
          backendMsg = (m['message'] ?? m['error'] ?? '').toString();
        } catch (_) {}
        setState(() {
          errorMessage = backendMsg.isNotEmpty
              ? backendMsg
              : "حدث خطأ: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "تعذر الاتصال بالخادم: $e";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "تسجيل الدخول",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: emailController,
                  decoration:
                  const InputDecoration(labelText: "البريد الإلكتروني"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration:
                  const InputDecoration(labelText: "كلمة المرور"),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                if (errorMessage != null)
                  Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                    onPressed: handleLogin, child: const Text("دخول")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}