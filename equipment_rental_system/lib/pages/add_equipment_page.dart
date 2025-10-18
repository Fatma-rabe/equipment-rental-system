import 'package:flutter/material.dart';
import 'package:equipment_rental_system/api_service.dart';
import 'edit_equipment_page.dart';

class AddEquipmentPage extends StatefulWidget {
  const AddEquipmentPage({Key? key}) : super(key: key);

  @override
  _AddEquipmentPageState createState() => _AddEquipmentPageState();
}

class _AddEquipmentPageState extends State<AddEquipmentPage> {
  final ApiService _api = ApiService();
  final List<Map<String, dynamic>> _equipment = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEquipment();
  }

  Future<void> _loadEquipment() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _api.getEquipment();
      setState(() {
        _equipment
          ..clear()
          ..addAll(items.cast<Map<String, dynamic>>());
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openAddDialog() async {
    final newEq = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _AddEquipmentDialog(),
    );
    if (newEq != null) {
      try {
        await _api.createEquipment(newEq);
        await _loadEquipment();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة المعدة بنجاح')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إضافة المعدة: $e')),
        );
      }
    }
  }

  Future<void> _editEquipment(Map<String, dynamic> current) async {
    final updated = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditEquipmentPage(
          equipmentId: (current['id'] ?? current['_id']) as String,
          currentData: current,
        ),
      ),
    );
    if (updated != null) {
      try {
        await _api.updateEquipment((updated['id'] ?? updated['_id']) as String, updated);
        await _loadEquipment();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تعديل المعدة بنجاح')),
        );
      } catch (e) {
        await _loadEquipment();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تعديل المعدة: $e')),
        );
      }
    }
  }

  Future<void> _deleteEquipment(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذه المعدة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _api.deleteEquipment(id);
        await _loadEquipment();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف المعدة بنجاح')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل حذف المعدة: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المعدات')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _equipment.isEmpty
              ? const Center(child: Text('No equipment available'))
              : RefreshIndicator(
                  onRefresh: _loadEquipment,
                  child: ListView.builder(
                    itemCount: _equipment.length,
                    itemBuilder: (context, index) {
                      final e = _equipment[index];
                      return ListTile(
                        title: Text(e['name']?.toString() ?? ''),
                        subtitle: Text('النوع: ${e['category'] ?? e['type']} • السعر: ${e['price']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editEquipment(e),
                              tooltip: 'تعديل',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteEquipment((e['id'] ?? e['_id']).toString()),
                              tooltip: 'حذف',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddEquipmentDialog extends StatefulWidget {
  const _AddEquipmentDialog();

  @override
  State<_AddEquipmentDialog> createState() => _AddEquipmentDialogState();
}

class _AddEquipmentDialogState extends State<_AddEquipmentDialog> {
  final nameController = TextEditingController();
  final typeController = TextEditingController();
  final priceController = TextEditingController();

  String pricingType = 'بالساعة';
  String? errorMessage;
  bool isLoading = false;

  void _save() async {
    final name = nameController.text.trim();
    final type = typeController.text.trim();
    final priceStr = priceController.text.trim();

    if (name.isEmpty || type.isEmpty || priceStr.isEmpty) {
      setState(() => errorMessage = 'يرجى ملء جميع الحقول');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final equipment = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'type': type,
      'price': double.tryParse(priceStr) ?? 0.0,
      'unit': pricingType == 'بالساعة' ? 'ساعة' : 'متر',
      'pricingType': pricingType == 'بالساعة' ? 'hour' : 'meter',
    };

    Navigator.pop(context, equipment);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة معدة جديدة'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'اسم المعدة'),
            ),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(labelText: 'النوع'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'السعر'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('نوع التأجير:'),
                const SizedBox(width: 16),
                Radio<String>(
                  value: 'بالساعة',
                  groupValue: pricingType,
                  onChanged: (v) => setState(() => pricingType = v!),
                ),
                const Text('بالساعة'),
                Radio<String>(
                  value: 'بالمتر',
                  groupValue: pricingType,
                  onChanged: (v) => setState(() => pricingType = v!),
                ),
                const Text('بالمتر'),
              ],
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        isLoading
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
            : ElevatedButton(onPressed: _save, child: const Text('حفظ')),
      ],
    );
  }
}
