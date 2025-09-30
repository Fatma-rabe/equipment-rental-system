import 'package:flutter/material.dart';
import 'admin_reply_page.dart';

class AdminMessagesPage extends StatelessWidget {
  final String userId;
  final String userEmail;

  const AdminMessagesPage({
    super.key,
    required this.userId,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('رسائل - $userEmail')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 0,
              itemBuilder: (context, index) {
                return const SizedBox.shrink();
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminReplyPage(
                      userId: userId,
                      userEmail: userEmail,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.reply),
              label: const Text('رد'),
            ),
          )
        ],
      ),
    );
  }
}