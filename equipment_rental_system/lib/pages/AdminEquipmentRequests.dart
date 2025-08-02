import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminEquipmentRequestsPage extends StatefulWidget {
  const AdminEquipmentRequestsPage({Key? key}) : super(key: key);

  @override
  State<AdminEquipmentRequestsPage> createState() => _AdminEquipmentRequestsPageState();
}

class _AdminEquipmentRequestsPageState extends State<AdminEquipmentRequestsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلبات تأجير المعدات')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('equipment_requests').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text('لا توجد طلبات حالياً'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final data = doc.data() as Map<String, dynamic>;
              final requestId = doc.id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('المستخدم: ${data['userName'] ?? '---'}'),
                      Text('المعدة: ${data['equipmentName'] ?? '---'}'),
                      Text('نوع التأجير: ${data['rentalType'] ?? '---'}'),
                      Text('الكمية: ${data['quantity'] ?? 0}'),
                      Text('سعر الوحدة: ${data['unitPrice'] ?? 0}'),
                      Text('الإجمالي: ${data['totalPrice'] ?? 0}'),
                      Text('الحالة: ${data['status'] ?? '---'}'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await _firestore.collection('equipment_requests').doc(requestId).update({
                                'status': 'approved',
                              });

                              await _firestore.collection('financial_reports').add({
                                'userId': data['userId'],
                                'source': 'equipment',
                                'amount': (data['totalPrice'] ?? 0),
                                'createdAt': FieldValue.serverTimestamp(),
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تمت الموافقة على الطلب')),
                              );
                            },
                            child: const Text('موافقة'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () async {
                              await _firestore.collection('equipment_requests').doc(requestId).delete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم رفض الطلب وحذفه')),
                              );
                            },
                            child: const Text('رفض'),
                          ),
                        ],
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
