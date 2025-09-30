import 'package:flutter/material.dart';

class AdminEquipmentRequestsPage extends StatefulWidget {
  const AdminEquipmentRequestsPage({Key? key}) : super(key: key);

  @override
  State<AdminEquipmentRequestsPage> createState() => _AdminEquipmentRequestsPageState();
}

class _AdminEquipmentRequestsPageState extends State<AdminEquipmentRequestsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلبات تأجير المعدات')),
      body: Builder(builder: (context) {
        // Placeholder static list without Firebase
        final requests = [
          {
            'id': 'er1',
            'userName': 'user1',
            'equipmentName': 'حفار',
            'rentalType': 'hour',
            'quantity': 2,
            'unitPrice': 200,
            'totalPrice': 400,
            'status': 'pending',
          }
        ];

        if (requests.isEmpty) {
          return const Center(child: Text('لا توجد طلبات حالياً'));
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final data = requests[index] as Map<String, dynamic>;
            final requestId = data['id'] as String;

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
                              // Placeholder: simulate approve and add to financial report
                              await Future.delayed(const Duration(milliseconds: 200));
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
                              // Placeholder: simulate delete
                              await Future.delayed(const Duration(milliseconds: 200));
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
      }),
    );
  }
}
