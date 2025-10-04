import 'package:flutter/material.dart';
import 'add_equipment_page.dart';
import 'edit_equipment_page.dart';

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({Key? key}) : super(key: key);

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  bool _isAdmin = true; // تعديل حسب الحالة الحقيقية للـ admin
  bool _isLoading = true;

  final List<Map<String, dynamic>> _equipment = [
    {'id': 'e1', 'name': 'حفار', 'type': 'ثقيل', 'price': 200, 'unit': 'ساعة', 'pricingType': 'hour'},
    {'id': 'e2', 'name': 'ونش', 'type': 'رفع', 'price': 150, 'unit': 'ساعة', 'pricingType': 'hour'},
  ];

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    // هنا ممكن تجيب الحالة الحقيقية للـ admin من SharedPreferences أو API
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      _isAdmin = true; // مثال لتفعيل الـ admin controls
      _isLoading = false;
    });
  }

  Future<void> _addEquipment() async {
    final newEq = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AddEquipmentPage()),
    );
    if (newEq != null) {
      setState(() => _equipment.add(newEq));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة المعدة بنجاح')),
      );
    }
  }

  Future<void> _editEquipment(Map<String, dynamic> current) async {
    final updated = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => EditEquipmentPage(
        equipmentId: current['id'] as String,
        currentData: current,
      )),
    );
    if (updated != null) {
      final idx = _equipment.indexWhere((e) => e['id'] == updated['id']);
      if (idx != -1) setState(() => _equipment[idx] = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تعديل المعدة بنجاح')),
      );
    }
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
      setState(() => _equipment.removeWhere((e) => e['id'] == id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف المعدة بنجاح')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قائمة المعدات')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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


