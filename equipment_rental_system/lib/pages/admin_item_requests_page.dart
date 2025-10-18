import 'package:flutter/material.dart';
import 'package:equipment_rental_system/api_service.dart';

class AdminItemRequestsPage extends StatefulWidget {
  const AdminItemRequestsPage({super.key});

  @override
  State<AdminItemRequestsPage> createState() => _AdminItemRequestsPageState();
}

class _AdminItemRequestsPageState extends State<AdminItemRequestsPage> {
  final ApiService _api = ApiService();
  final List<Map<String, dynamic>> _requests = [];
  bool _loading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await _api.listWarehouseRequestsAdmin();
      _requests
        ..clear()
        ..addAll(list.cast<Map<String, dynamic>>().map((e) => {
          'id': (e['_id'] ?? e['id']).toString(),
          'itemName': e['warehouseItem']?['Itemname'] ?? '-',
          'quantity': e['quantityRequested'] ?? 0,
          'totalPrice': e['amount'] ?? 0,
          'status': e['status'] ?? 'pending',
        }));
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _approve(String id) async {
    try {
      await _api.approveWarehouseRequest(id);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الموافقة على الطلب')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الموافقة: $e')));
      }
    }
  }

  Future<void> _reject(String id) async {
    try {
      await _api.rejectWarehouseRequest(id);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفض الطلب')));
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
      appBar: AppBar(title: Text('طلبات الأصناف')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _requests.isEmpty
          ? Center(child: Text('لا توجد طلبات حالياً.'))
          : ListView.builder(
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final data = _requests[index];
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
                          onPressed: () => _approve(requestId),
                        ),
                        IconButton(
                          icon: Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => _reject(requestId),
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

