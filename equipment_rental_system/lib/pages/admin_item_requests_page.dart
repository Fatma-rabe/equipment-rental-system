import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminItemRequestsPage extends StatelessWidget {
  const AdminItemRequestsPage({super.key});

  void updateRequestStatus(String requestId, String status) {
    FirebaseFirestore.instance.collection('item_requests').doc(requestId).update({
      'status': status,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('طلبات الأصناف')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('item_requests')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return Center(child: Text('لا توجد طلبات حالياً.'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index].data() as Map<String, dynamic>;
              final requestId = requests[index].id;

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
                        onPressed: () => updateRequestStatus(requestId, 'accepted'),
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => updateRequestStatus(requestId, 'rejected'),
                      ),
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

