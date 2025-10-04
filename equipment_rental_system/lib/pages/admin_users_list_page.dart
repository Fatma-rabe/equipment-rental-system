import 'package:flutter/material.dart';
import 'package:equipment_rental_system/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_direct_chat_page.dart';

class AdminUsersListPage extends StatefulWidget {
  const AdminUsersListPage({super.key});

  @override
  State<AdminUsersListPage> createState() => _AdminUsersListPageState();
}

class _AdminUsersListPageState extends State<AdminUsersListPage> {
  final UserService _userService = UserService();
  final List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await _userService.listUsers();
      setState(() {
        _users
          ..clear()
          ..addAll(list);
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المستخدمون')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Text('لا يوجد مستخدمين.'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final u = _users[index];
                      final email = (u['email'] ?? '').toString();
                      final id = (u['id'] ?? u['_id'] ?? '').toString();
                      return ListTile(
                        title: Text(email.isEmpty ? 'بدون بريد' : email),
                        trailing: const Icon(Icons.chat),
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminDirectChatPage(
                                userId: id,
                                userEmail: email,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
