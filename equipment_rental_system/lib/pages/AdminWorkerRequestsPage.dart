import 'package:flutter/material.dart';

class AdminWorkerRequestsPage extends StatelessWidget {
  const AdminWorkerRequestsPage({super.key});

  Future<void> approveRequest(String requestId) async {
    // Placeholder: simulate approve
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> rejectRequest(String requestId) async {
    // Placeholder: simulate reject/delete
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('طلبات العمال')),
      body: Builder(builder: (context) {
        // Placeholder static list of worker requests
        final requests = [
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

        if (requests.isEmpty) {
          return Center(child: Text('لا توجد طلبات حالياً'));
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final data = requests[index] as Map<String, dynamic>;
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
                            onPressed: () => approveRequest(requestId),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton.icon(
                            icon: Icon(Icons.close),
                            label: Text('رفض'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () => rejectRequest(requestId),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
      }),
    );
  }
}
