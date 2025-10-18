import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:equipment_rental_system/api_service.dart';
import 'add_equipment_page.dart';
import 'edit_equipment_page.dart';
import 'equipment_rental_request_page.dart';

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({Key? key}) : super(key: key);

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  bool _isAdmin = false;
  bool _isLoading = true;
  String? _error;
  final ApiService _api = ApiService();
  final List<Map<String, dynamic>> _equipment = [];

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    String role = 'user';
    if (token != null) {
      try {
        final payload = Jwt.parseJwt(token);
        role = (payload['role']?.toString().toLowerCase() ?? 'user');
      } catch (_) {}
    }
    setState(() {
      _isAdmin = role == 'admin';
    });
    await _loadEquipment();
  }

  Future<void> _loadEquipment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await _api.getEquipment();
      _equipment
        ..clear()
        ..addAll(list.map<Map<String, dynamic>>((e) => {
              'id': e['_id'] ?? e['id'],
              'name': e['name'],
              'type': e['category'] ?? e['type'],
              'price': e['price'],
              // default to hour as backend has only price
              'unit': 'ساعة',
              'pricingType': 'hour',
            }));
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addEquipment() async {
    final newEq = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AddEquipmentPage()),
    );
    if (newEq != null) await _loadEquipment();
  }

  Future<void> _editEquipment(Map<String, dynamic> current) async {
    final updated = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => EditEquipmentPage(
        equipmentId: current['id'] as String,
        currentData: current,
      )),
    );
    if (updated != null) await _loadEquipment();
  }

  Future<void> _deleteEquipment(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذه المعدة؟'),
        actions: [
          TextButton(child: const Text('إلغاء'), onPressed: () => Navigator.pop(context, false)),
          TextButton(
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _api.deleteEquipment(id);
        await _loadEquipment();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف المعدة بنجاح')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل حذف المعدة: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قائمة المعدات')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _equipment.isEmpty
                  ? const Center(child: Text('لا توجد معدات حالياً'))
                  : ListView.builder(
        itemCount: _equipment.length,
        itemBuilder: (context, index) {
          final data = _equipment[index];
          final id = data['id'] as String;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] ?? '',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text('النوع: ${data['type'] ?? ''} • السعر: ${data['price']}'),
                  const SizedBox(height: 8),
                  if (_isAdmin)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editEquipment(data),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteEquipment(id),
                        ),
                      ],
                    ),
                  if (!_isAdmin)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EquipmentRentalRequestPage(
                                equipmentId: id,
                                equipmentData: data,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart_checkout),
                        label: const Text('طلب تأجير'),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: !_isLoading && _isAdmin
          ? FloatingActionButton(
        onPressed: _addEquipment,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}


