import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_rental_system/pages/UserDashboardPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'admin_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  void handleLogin() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = credential.user!.uid;


      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final role = data['role'];

       if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboardPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UserDashboardPage()),
          );
        }
      } else {
        setState(() {
          errorMessage = "لم يتم العثور على بيانات المستخدم!";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "فشل تسجيل الدخول: ${e.toString()}";
      });
    }

    setState(() {
      isLoading = false;
    });
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
                Text("تسجيل الدخول", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                SizedBox(height: 32),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "البريد الإلكتروني"),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: "كلمة المرور"),
                  obscureText: true,
                ),
                SizedBox(height: 24),
                if (errorMessage != null)
                  Text(errorMessage!, style: TextStyle(color: Colors.red)),
                SizedBox(height: 16),
                isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: handleLogin,
                  child: Text("دخول"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

