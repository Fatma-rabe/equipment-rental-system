import 'package:flutter/material.dart';
import 'package:equipment_rental_system/api_service.dart';

class RequestItemPage extends StatefulWidget {
  const RequestItemPage({super.key});

  @override
  State<RequestItemPage> createState() => _RequestItemPageState();
}

class _RequestItemPageState extends State<RequestItemPage> {
  String? selectedItemId;
  Map<String, dynamic>? selectedItemData;
  final quantityController = TextEditingController();
  double totalPrice = 0;
  bool _loading = true;
  String? _error;
  final List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await ApiService().listWarehouseItems();
      _items
        ..clear()
        ..addAll(list.cast<Map<String, dynamic>>().map((e) => {
          'id': (e['_id'] ?? e['id']).toString(),
          'name': e['Itemname'] ?? e['name'] ?? '-',
          'price': (e['price'] as num?)?.toDouble() ?? 0.0,
        }));
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void calculateTotal() {
    if (selectedItemData != null && quantityController.text.isNotEmpty) {
      final quantity = int.tryParse(quantityController.text) ?? 0;
      final unitPrice = (selectedItemData!['price'] as num).toDouble();


      setState(() {
        totalPrice = quantity * unitPrice;
      });
    }
  }

  void sendRequest() async {
    if (selectedItemId == null || quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار الصنف والكمية')));
      return;
    }
    final qty = int.tryParse(quantityController.text) ?? 0;
    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كمية غير صحيحة')));
      return;
    }
    try {
      await ApiService().requestWarehouseItem(itemId: selectedItemId!, quantity: qty);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الطلب بنجاح')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل إرسال الطلب: $e')));
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('طلب صنف من المخزن')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'اختر الصنف'),
              value: selectedItemId,
              items: _items.map((item) {
                return DropdownMenuItem<String>(
                  value: item['id'] as String,
                  child: Text(item['name'].toString()),
                  onTap: () {
                    selectedItemData = item;
                  },
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedItemId = value;
                  calculateTotal();
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(labelText: 'الكمية المطلوبة'),
              keyboardType: TextInputType.number,
              onChanged: (_) => calculateTotal(),
            ),
            SizedBox(height: 16),
            if (selectedItemData != null)
              Text('السعر / وحدة: ${selectedItemData!['price']}'),
            SizedBox(height: 8),
            Text('الإجمالي: $totalPrice'),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: sendRequest,
              child: Text('إرسال الطلب'),
            ),
          ],
        ),
      ),
    );
  }
}
