import 'package:flutter/material.dart';
import 'package:equipment_rental_system/api_service.dart';

class AdminMaintenanceRequestsPage extends StatefulWidget {
  const AdminMaintenanceRequestsPage({super.key});

  @override
  State<AdminMaintenanceRequestsPage> createState() =>
      _AdminMaintenanceRequestsPageState();
}

class _AdminMaintenanceRequestsPageState
    extends State<AdminMaintenanceRequestsPage> {
  final ApiService _api = ApiService();
  final List<Map<String, dynamic>> _requests = [];
  bool _loading = true;
  String? _error;

  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    // dispose all controllers
    for (var ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _api.listMaintenanceRequestsAdmin();
      _requests
        ..clear()
        ..addAll(list.cast<Map<String, dynamic>>().map((e) => {
              'id': (e['_id'] ?? e['id']).toString(),
              'userName': e['user']?['name'] ?? '-',
              'description': e['name'] ?? e['message'] ?? '-',
              'status': e['status'] ?? 'pending',
              'price': e['amount'],
            }));
      // rebuild controllers
      for (var req in _requests) {
        _controllers[req['id']] = TextEditingController(
          text: req['price']?.toString() ?? '',
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _approve(String id) async {
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

    try {
      await _api.approveMaintenanceRequest(id, price);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت الموافقة على طلب الصيانة')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الموافقة: $e')));
      }
    }
  }

  Future<void> _reject(String id) async {
    try {
      await _api.rejectMaintenanceRequest(id);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم رفض الطلب')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الرفض: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلبات الصيانة')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _requests.isEmpty
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