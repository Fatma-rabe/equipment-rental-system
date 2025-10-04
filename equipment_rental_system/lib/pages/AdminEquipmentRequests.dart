import 'package:flutter/material.dart';

class AdminEquipmentRequestsPage extends StatefulWidget {
  const AdminEquipmentRequestsPage({Key? key}) : super(key: key);

  @override
  State<AdminEquipmentRequestsPage> createState() => _AdminEquipmentRequestsPageState();
}

class _AdminEquipmentRequestsPageState extends State<AdminEquipmentRequestsPage> {
  final List<Map<String, dynamic>> _requests = [
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

  void _approve(String id) {
    final idx = _requests.indexWhere((r) => r['id'] == id);
    if (idx != -1) {
      setState(() {
        _requests[idx]['status'] = 'accepted';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت الموافقة على الطلب')),
      );
    }
  }

  void _reject(String id) {
    setState(() {
      _requests.removeWhere((r) => r['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم رفض الطلب وحذفه')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلبات تأجير المعدات')),
      body: Builder(builder: (context) {
        if (_requests.isEmpty) {
          return const Center(child: Text('لا توجد طلبات حالياً'));
        }

        return ListView.builder(
          itemCount: _requests.length,
          itemBuilder: (context, index) {
            final data = _requests[index];
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
                          onPressed: () => _approve(requestId),
                          child: const Text('موافقة'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () => _reject(requestId),
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
