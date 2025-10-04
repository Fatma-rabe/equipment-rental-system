import 'package:flutter/material.dart';
import 'package:equipment_rental_system/services/user_service.dart';

class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  State<AdminUserManagementPage> createState() => _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
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

  Future<void> _createOrEdit({Map<String, dynamic>? user}) async {
    final isEdit = user != null;
    final emailCtrl = TextEditingController(text: user?['email']?.toString() ?? '');
    final nameCtrl = TextEditingController(text: user?['name']?.toString() ?? '');
    final passCtrl = TextEditingController();
    String role = (user?['role']?.toString() ?? 'user');

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'تعديل مستخدم' : 'مستخدم جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(decoration: const InputDecoration(labelText: 'البريد'), controller: emailCtrl),
              TextField(decoration: const InputDecoration(labelText: 'الاسم'), controller: nameCtrl),
              if (!isEdit)
                TextField(decoration: const InputDecoration(labelText: 'كلمة المرور'), controller: passCtrl, obscureText: true),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'الدور'),
                value: role,
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('User')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (v) { if (v != null) role = v; },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () {
            final email = emailCtrl.text.trim();
            final name = nameCtrl.text.trim();
            final pass = passCtrl.text.trim();
            if (email.isEmpty || (!isEdit && pass.isEmpty)) return;
            Navigator.pop(context, {
              'email': email,
              if (name.isNotEmpty) 'name': name,
              'password': pass,
              'role': role,
            });
          }, child: Text(isEdit ? 'حفظ' : 'إنشاء')),
        ],
      ),
    );

    if (result == null) return;

    if (isEdit) {
      // optimistic update
      final idx = _users.indexWhere((u) => (u['id'] ?? u['_id']) == (user!['id'] ?? user['_id']));
      if (idx != -1) setState(() => _users[idx] = { ..._users[idx], ...result });
      try {
        final id = (user['id'] ?? user['_id']).toString();
        final saved = await _userService.updateUser(id, result);
        final i2 = _users.indexWhere((u) => (u['id'] ?? u['_id']).toString() == (saved['id'] ?? saved['_id']).toString());
        if (i2 != -1) setState(() => _users[i2] = saved);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ التعديلات')));
      } catch (e) {
        await _load();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل التعديل: $e')));
      }
    } else {
      // optimistic creation
      final temp = { 'id': DateTime.now().millisecondsSinceEpoch.toString(), ...result };
      setState(() => _users.add(temp));
      try {
        final created = await _userService.createUser(
          email: result['email'],
          password: result['password'],
          name: result['name'],
          role: result['role'] ?? 'user',
        );
        final idx = _users.indexWhere((u) => u['id'] == temp['id']);
        if (idx != -1) setState(() => _users[idx] = created);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء المستخدم')));
      } catch (e) {
        setState(() => _users.removeWhere((u) => u['id'] == temp['id']));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الإنشاء: $e')));
      }
    }
  }

  Future<void> _delete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل تريد حذف هذا المستخدم؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;

    final idx = _users.indexWhere((u) => (u['id'] ?? u['_id']).toString() == id);
    if (idx == -1) return;
    final removed = _users.removeAt(idx);
    setState(() {});
    try {
      await _userService.deleteUser(id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف المستخدم')));
    } catch (e) {
      _users.insert(idx, removed);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الحذف: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المستخدمين')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Text('لا يوجد مستخدمون'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final u = _users[index];
                      final id = (u['id'] ?? u['_id'] ?? '').toString();
                      final email = (u['email'] ?? '').toString();
                      final role = (u['role'] ?? 'user').toString();
                      return ListTile(
                        title: Text(email.isEmpty ? 'بدون بريد' : email),
                        subtitle: Text('الدور: $role'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _createOrEdit(user: u),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _delete(id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createOrEdit,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
