import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminMaintenanceRequestsPage extends StatefulWidget {
  const AdminMaintenanceRequestsPage({super.key});

  @override
  State<AdminMaintenanceRequestsPage> createState() =>
      _AdminMaintenanceRequestsPageState();
}

class _AdminMaintenanceRequestsPageState
    extends State<AdminMaintenanceRequestsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلبات الصيانة')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('maintenance_requests')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text('لا توجد طلبات صيانة حالياً'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final data = doc.data() as Map<String, dynamic>;
              final requestId = doc.id;
              final TextEditingController priceController = TextEditingController(
                text: data['price']?.toString() ?? '',
              );

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('اسم المستخدم: ${data['userName'] ?? '---'}'),
                      Text('الوصف: ${data['description'] ?? '---'}'),
                      Text('الحالة: ${data['status'] ?? '---'}'),
                      const SizedBox(height: 10),
                      TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'سعر الصيانة',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final price = double.tryParse(priceController.text.trim());
                              if (price == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('يرجى إدخال سعر صالح')),
                                );
                                return;
                              }

                              await _firestore.collection('maintenance_requests').doc(requestId).update({
                                'status': 'approved',
                                'price': price,
                              });

                              await _firestore.collection('financial_reports').add({
                                'userId': data['userId'],
                                'source': 'maintenance',
                                'amount': price,
                                'createdAt': FieldValue.serverTimestamp(),
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تمت الموافقة على الطلب وإضافة السعر')),
                              );
                            },
                            child: const Text('موافقة'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () async {
                              await _firestore.collection('maintenance_requests').doc(requestId).delete();
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
