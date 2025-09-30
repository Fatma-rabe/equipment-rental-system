import 'package:flutter/material.dart';

class AdminMaintenanceRequestsPage extends StatefulWidget {
  const AdminMaintenanceRequestsPage({super.key});

  @override
  State<AdminMaintenanceRequestsPage> createState() =>
      _AdminMaintenanceRequestsPageState();
}

class _AdminMaintenanceRequestsPageState
    extends State<AdminMaintenanceRequestsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلبات الصيانة')),
      body: Builder(
        builder: (context) {
          // Placeholder static list of maintenance requests without Firebase
          final requests = [
            {
              'id': 'mr1',
              'userName': 'user1',
              'description': 'صيانة معدة',
              'status': 'pending',
              'price': null,
            }
          ];

          if (requests.isEmpty) {
            return const Center(child: Text('لا توجد طلبات صيانة حالياً'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index] as Map<String, dynamic>;
              final requestId = data['id'] as String;
              final TextEditingController priceController =
              TextEditingController(
                text: data['price']?.toString() ?? '',
              );

              return Card(
                margin:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                              final price = double.tryParse(
                                  priceController.text.trim());
                              if (price == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                      Text('يرجى إدخال سعر صالح')),
                                );
                                return;
                              }
                              // Placeholder: simulate approve and add to financial report
                              await Future.delayed(
                                  const Duration(milliseconds: 200));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'تمت الموافقة على الطلب وإضافة السعر')),
                              );
                            },
                            child: const Text('موافقة'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () async {
                              // Placeholder: simulate delete
                              await Future.delayed(
                                  const Duration(milliseconds: 200));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('تم رفض الطلب وحذفه')),
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