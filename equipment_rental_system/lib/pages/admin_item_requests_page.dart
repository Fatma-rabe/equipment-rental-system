import 'package:flutter/material.dart';

class AdminItemRequestsPage extends StatelessWidget {
  const AdminItemRequestsPage({super.key});

  void updateRequestStatus(String requestId, String status) {
    // Placeholder: simulate update
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('طلبات الأصناف')),
      body: Builder(builder: (context) {
        // Placeholder static list
        final requests = [
          {'id': 'r1', 'itemName': 'أسمنت', 'quantity': 2, 'totalPrice': 100, 'status': 'pending'},
          {'id': 'r2', 'itemName': 'حديد', 'quantity': 1, 'totalPrice': 120, 'status': 'pending'},
        ];

        if (requests.isEmpty) {
          return Center(child: Text('لا توجد طلبات حالياً.'));
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final data = requests[index];
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
        })
    );
  }
}

