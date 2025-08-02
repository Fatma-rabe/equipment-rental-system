import 'package:flutter/material.dart';
import 'user_item_request_page.dart'; // تأكدي إن الملف دا موجود

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الصفحة الرئيسية - المستخدم'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'مرحبًا بك في نظام تأجير المعدات',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RequestItemPage()),
                );
              },
              child: Text('طلب معدات'),
            ),
          ],
        ),
      ),
    );
  }
}

