import 'package:cloud_firestore/cloud_firestore.dart';
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('senderId', isEqualTo: userId)
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(msg['message'] ?? ''),
                      subtitle: Text(msg['timestamp']?.toDate().toString() ?? ''),
                    );
                  },
                );
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