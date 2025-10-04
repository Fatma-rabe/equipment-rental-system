import 'package:flutter/material.dart';
import 'EditWorkerPage.dart';
import 'add_worker_page.dart';

class AdminWorkersPage extends StatefulWidget {
  const AdminWorkersPage({super.key});

  @override
  State<AdminWorkersPage> createState() => _AdminWorkersPageState();
}

class _AdminWorkersPageState extends State<AdminWorkersPage> {
  final List<Map<String, dynamic>> _workers = [
    {'id': 'w1', 'name': 'عامل 1', 'jobTitle': 'نجار', 'dailySalary': 100, 'phone': ''},
    {'id': 'w2', 'name': 'عامل 2', 'jobTitle': 'حداد', 'dailySalary': 120, 'phone': ''},
  ];

  Future<void> _addWorker() async {
    final newWorker = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const AddWorkerPage()),
    );
    if (newWorker != null) {
      setState(() {
        _workers.add(newWorker);
      });
    }
  }

  Future<void> _editWorker(int index) async {
    final updated = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditWorkerPage(
          workerId: _workers[index]['id'] as String,
          workerData: Map<String, dynamic>.from(_workers[index]),
        ),
      ),
    );
    if (updated != null) {
      setState(() {
        _workers[index] = updated;
      });
    }
  }

  Future<void> _deleteWorker(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد أنك تريد حذف هذا العامل؟'),
        actions: [
          TextButton(
            child: Text('إلغاء'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text('حذف'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        _workers.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إدارة العمال')),
      body: _workers.isEmpty
          ? Center(child: Text('لا يوجد عمال حالياً'))
          : ListView.builder(
              itemCount: _workers.length,
              itemBuilder: (context, index) {
                final data = _workers[index];
                return ListTile(
                  title: Text(data['name'] ?? ''),
                  subtitle: Text(data['jobTitle'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${data['dailySalary']} ج.م'),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editWorker(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteWorker(index),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addWorker,
        child: Icon(Icons.add),
      ),
    );
  }
}
