import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminWorkerRequestsPage extends StatelessWidget {
  const AdminWorkerRequestsPage({super.key});

  Future<void> approveRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('worker_requests')
        .doc(requestId)
        .update({'status': 'approved'});
  }

  Future<void> rejectRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('worker_requests')
        .doc(requestId)
        .delete(); // رفض = حذف
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('طلبات العمال')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('worker_requests')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return Center(child: Text('لا توجد طلبات حالياً'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index].data() as Map<String, dynamic>;
              final requestId = requests[index].id;

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
        },
      ),
    );
  }
}
