import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

class AdminDirectChatPage extends StatefulWidget {
  final String userId;
  final String userEmail;

  const AdminDirectChatPage({super.key, required this.userId, required this.userEmail});

  @override
  State<AdminDirectChatPage> createState() => _AdminDirectChatPageState();
}

class _AdminDirectChatPageState extends State<AdminDirectChatPage> {
  late IO.Socket socket;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  String? _currentEmail; // admin email decoded from token

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  Future<void> _initSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token != null && token.isNotEmpty) {
      try {
        final payload = Jwt.parseJwt(token);
        _currentEmail = payload['email']?.toString();
      } catch (_) {}
    }

    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {
        'token': token,
      },
    });

    socket.connect();

    socket.onConnect((_) {
      // Optionally, join a room for this user
      socket.emit('join_room', { 'room': widget.userEmail });
    });

    socket.on('receive_message', (data) {
      final String message = (data['message'] ?? '').toString();
      final String sender = (data['sender'] ?? '').toString();
      final String? receiver = data['receiver']?.toString();

      // Basic filter: show messages either from the selected user, or sent by me to that user
      final isRelevant = sender == widget.userEmail || receiver == widget.userEmail;
      if (!isRelevant) return;

      final bool isMe = _currentEmail != null && sender == _currentEmail;
      setState(() {
        _messages.insert(0, {
          'message': message,
          'sender': sender,
          'isMe': isMe,
        });
      });
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });

    socket.onDisconnect((_) {});
    socket.onError((err) {});
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Optimistic UI
    setState(() {
      _messages.insert(0, {
        'message': text,
        'sender': _currentEmail ?? 'Admin',
        'isMe': true,
      });
    });

    socket.emit('send_message', {
      'message': text,
      'receiver': widget.userEmail,
    });

    _messageController.clear();
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    socket.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('دردشة: ${widget.userEmail}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              physics: const BouncingScrollPhysics(),
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final String text = (msg['message'] ?? '').toString();
                final String sender = (msg['sender'] ?? '').toString();
                final bool isMe = (msg['isMe'] ?? false) as bool;
                return _buildMessageBubble(text: text, sender: sender, isMe: isMe);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: 'اكتب رسالة...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMessageBubble({required String text, required String sender, required bool isMe}) {
    final theme = Theme.of(context);
    final bgColor = isMe ? (Colors.green[400] ?? theme.colorScheme.primary) : (Colors.grey[300] ?? theme.colorScheme.surfaceVariant);
    final fgColor = isMe ? Colors.white : Colors.black87;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(isMe ? 14 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 14),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(color: fgColor),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isMe)
                    Text(
                      sender,
                      style: theme.textTheme.labelSmall?.copyWith(color: fgColor.withOpacity(0.8)),
                    )
                  else ...[
                    Icon(
                      Icons.done_all,
                      size: 16,
                      color: fgColor.withOpacity(0.9),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
