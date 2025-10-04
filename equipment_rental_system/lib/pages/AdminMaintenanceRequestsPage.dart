import 'package:flutter/material.dart';

class AdminMaintenanceRequestsPage extends StatefulWidget {
  const AdminMaintenanceRequestsPage({super.key});

  @override
  State<AdminMaintenanceRequestsPage> createState() =>
      _AdminMaintenanceRequestsPageState();
}

class _AdminMaintenanceRequestsPageState
    extends State<AdminMaintenanceRequestsPage> {
  final List<Map<String, dynamic>> _requests = [
    {
      'id': 'mr1',
      'userName': 'user1',
      'description': 'صيانة معدة',
      'status': 'pending',
      'price': null,
    }
  ];

  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // initialize controllers for existing requests
    for (var req in _requests) {
      _controllers[req['id']] = TextEditingController(
        text: req['price']?.toString() ?? '',
      );
    }
  }

  @override
  void dispose() {
    // dispose all controllers
    for (var ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _approve(String id) {
    final controller = _controllers[id];
    if (controller == null) return;

    final price = double.tryParse(controller.text.trim());
    if (price == null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال سعر صالح')),
      );
      return;
    }

    final idx = _requests.indexWhere((r) => r['id'] == id);
    if (idx != -1) {
      setState(() {
        _requests[idx]['status'] = 'accepted';
        _requests[idx]['price'] = price;
      });

      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت الموافقة على طلب الصيانة')),
      );

      // TODO: send approval to backend
    }
  }

  void _reject(String id) {
    setState(() {
      _requests.removeWhere((r) => r['id'] == id);
      _controllers.remove(id)?.dispose();
    });

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم رفض الطلب وحذفه')),
    );

    // TODO: send rejection to backend
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلبات الصيانة')),
      body: _requests.isEmpty
          ? const Center(child: Text('لا توجد طلبات صيانة حالياً'))
          : ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final data = _requests[index];
          final requestId = data['id'] as String;
          final controller = _controllers[requestId]!;

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
                    controller: controller,
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
                        onPressed: () => _approve(requestId),
                        child: const Text('موافقة'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
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
      ),
    );
  }
}