import 'package:flutter/material.dart';
import 'package:equipment_rental_system/api_service.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'admin_dashboard.dart';
import 'package:equipment_rental_system/pages/UserDashboardPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      final result = await ApiService().login(email, password);

      final token = result['token'];
      if (token == null) {
        setState(() {
          errorMessage = result['message']?.toString() ??
              "فشل تسجيل الدخول: لا يوجد توكن";
        });
        return;
      }

      // Save token for socket authentication
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);

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