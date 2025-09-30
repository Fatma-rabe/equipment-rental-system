import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'login_page.dart';


void main() {
  runApp(MyApp());
}

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Center(child: Text('مرحبًا بك!')),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام تأجير المعدات',
      theme: ThemeData(
        fontFamily: 'Cairo',
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      routes: {
        '/dashboard': (context) => DashboardPage(),
        '/admin': (context) => AdminDashboardPage(),
      },
    );
  }
}
