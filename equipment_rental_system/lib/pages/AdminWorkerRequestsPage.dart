import 'package:flutter/material.dart';

class AdminWorkerRequestsPage extends StatefulWidget {
  const AdminWorkerRequestsPage({super.key});

  @override
  State<AdminWorkerRequestsPage> createState() => _AdminWorkerRequestsPageState();
}

class _AdminWorkerRequestsPageState extends State<AdminWorkerRequestsPage> {
  final List<Map<String, dynamic>> _requests = [
    {
      'id': 'wr1',
      'workerName': 'عامل 1',
      'days': 3,
      'dailySalary': 100,
      'total': 300,
      'userName': 'user1',
      'status': 'pending'
    }
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
      appBar: AppBar(title: Text('طلبات العمال')),
      body: _requests.isEmpty
          ? Center(child: Text('لا توجد طلبات حالياً'))
          : ListView.builder(
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final data = _requests[index];
                final requestId = data['id'] as String;

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('اسم العامل: ${data['workerName'] ?? ''}', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('عدد الأيام: ${data['days']}'),
                        Text('الأجر اليومي: ${data['dailySalary']} ج.م'),
                        Text('الإجمالي: ${data['total']} ج.م'),
                        Text('اسم المستخدم: ${data['userName'] ?? ''}'),
                        SizedBox(height: 10),
                        Text('الحالة: ${data['status']}', style: TextStyle(color: Colors.blue)),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              icon: Icon(Icons.check),
                              label: Text('موافقة'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              onPressed: () => _approve(requestId),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton.icon(
                              icon: Icon(Icons.close),
                              label: Text('رفض'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () => _reject(requestId),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
