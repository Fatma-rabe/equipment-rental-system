import 'package:flutter/material.dart';
import 'admin_messages_page.dart';

class AdminChatPage extends StatelessWidget {
  const AdminChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('محادثات المستخدمين')),
      body: Builder(
        builder: (context) {
          // Placeholder static list of users
          final users = [
            {'id': 'u1', 'email': 'user1@example.com'},
            {'id': 'u2', 'email': 'user2@example.com'},
          ];

          if (users.isEmpty) {
            return const Center(child: Text('لا يوجد مستخدمين.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userDoc = users[index];
              final userId = userDoc['id'] as String;
              final userEmail = userDoc['email'] ?? 'بلا بريد';

              return ListTile(
                title: Text(userEmail),
                trailing: const Icon(Icons.chat),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminMessagesPage(
                        userId: userId,
                        userEmail: userEmail,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}