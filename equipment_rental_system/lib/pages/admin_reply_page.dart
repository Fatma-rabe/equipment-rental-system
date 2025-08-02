import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminReplyPage extends StatefulWidget {
  final String userId;
  final String userEmail;

  const AdminReplyPage({super.key, required this.userId, required this.userEmail});

  @override
  State<AdminReplyPage> createState() => _AdminReplyPageState();
}

class _AdminReplyPageState extends State<AdminReplyPage> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await FirebaseFirestore.instance.collection('messages').add({
      'message': text,
      'senderId': 'admin',
      'receiverId': widget.userId,
      'sender': 'admin',
      'timestamp': FieldValue.serverTimestamp(),
    });

    _controller.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال الرسالة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الرد على ${widget.userEmail}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'اكتب الرسالة هنا...',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send),
              label: const Text('إرسال'),
            ),
          ],
        ),
      ),
    );
  }
}