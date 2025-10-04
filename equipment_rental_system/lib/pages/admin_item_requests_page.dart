import 'package:flutter/material.dart';

class AdminItemRequestsPage extends StatefulWidget {
  const AdminItemRequestsPage({super.key});

  @override
  State<AdminItemRequestsPage> createState() => _AdminItemRequestsPageState();
}

class _AdminItemRequestsPageState extends State<AdminItemRequestsPage> {
  final List<Map<String, dynamic>> _requests = [
    {'id': 'r1', 'itemName': 'أسمنت', 'quantity': 2, 'totalPrice': 100, 'status': 'pending'},
    {'id': 'r2', 'itemName': 'حديد', 'quantity': 1, 'totalPrice': 120, 'status': 'pending'},
  ];

  void _approve(String id) {
    final idx = _requests.indexWhere((r) => r['id'] == id);
    if (idx != -1) {
      setState(() => _requests[idx]['status'] = 'accepted');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الموافقة على الطلب')));
    }
  }

  void _reject(String id) {
    setState(() => _requests.removeWhere((r) => r['id'] == id));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفض الطلب وحذفه')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('طلبات الأصناف')),
      body: _requests.isEmpty
          ? Center(child: Text('لا توجد طلبات حالياً.'))
          : ListView.builder(
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final data = _requests[index];
                final requestId = data['id'] as String;

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text('الصنف: ${data['itemName']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الكمية: ${data['quantity']}'),
                        Text('السعر الكلي: ${data['totalPrice']}'),
                        Text('الحالة: ${data['status']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () => _approve(requestId),
                        ),
                        IconButton(
                          icon: Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => _reject(requestId),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

