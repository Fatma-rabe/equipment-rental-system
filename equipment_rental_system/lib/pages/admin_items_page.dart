import 'package:flutter/material.dart';

class AdminItemsPage extends StatefulWidget {
  const AdminItemsPage({super.key});

  @override
  State<AdminItemsPage> createState() => _AdminItemsPageState();
}

class _AdminItemsPageState extends State<AdminItemsPage> {
  final List<Map<String, dynamic>> _items = [
    {'id': 'i1', 'name': 'أسمنت', 'quantity': 10, 'price': 50},
    {'id': 'i2', 'name': 'حديد', 'quantity': 5, 'price': 120},
  ];

  void _onAddItem() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const AddItemDialog(),
    );
    if (result != null) {
      setState(() {
        _items.add(result);
      });
    }
  }

  void _onEditItem(int index) async {
    final current = _items[index];
    final updated = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => EditItemDialog(
        itemId: current['id'] as String,
        currentData: Map<String, dynamic>.from(current),
      ),
    );
    if (updated != null) {
      setState(() {
        _items[index] = updated;
      });
    }
  }

  void _onDeleteItem(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل أنت متأكد أنك تريد حذف هذا الصنف؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("حذف"),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        _items.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إدارة المخزن")),
      body: _items.isEmpty
          ? const Center(child: Text("لا يوجد أصناف حالياً"))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final data = _items[index];
                return ListTile(
                  title: Text(data['name']?.toString() ?? ''),
                  subtitle: Text("الكمية: ${data['quantity']} - السعر: ${data['price']}/وحدة"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _onEditItem(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _onDeleteItem(index),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddItemDialog extends StatefulWidget {
  const AddItemDialog({super.key});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  void saveItem() async {
    final name = nameController.text.trim();
    final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
    final price = double.tryParse(priceController.text.trim()) ?? 0.0;

    if (name.isNotEmpty) {
      // Return the created item to parent for immediate UI update
      final newItem = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'quantity': quantity,
        'price': price,
      };
      Navigator.pop(context, newItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("إضافة صنف جديد"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "اسم الصنف"),
          ),
          TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "الكمية"),
          ),
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "السعر/الوحدة"),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
        ElevatedButton(onPressed: saveItem, child: const Text("إضافة")),
      ],
    );
  }
}

class EditItemDialog extends StatefulWidget {
  final String itemId;
  final Map<String, dynamic> currentData;

  const EditItemDialog({super.key, required this.itemId, required this.currentData});

  @override
  State<EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  late TextEditingController nameController;
  late TextEditingController quantityController;
  late TextEditingController priceController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentData['name']);
    quantityController = TextEditingController(text: widget.currentData['quantity'].toString());
    priceController = TextEditingController(text: widget.currentData['price'].toString());
  }

  void updateItem() async {
    final updated = {
      'id': widget.itemId,
      'name': nameController.text.trim(),
      'quantity': int.tryParse(quantityController.text.trim()) ?? 0,
      'price': double.tryParse(priceController.text.trim()) ?? 0.0,
    };
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("تعديل بيانات الصنف"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "اسم الصنف"),
          ),
          TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "الكمية"),
          ),
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "السعر/الوحدة"),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
        ElevatedButton(onPressed: updateItem, child: const Text("تحديث")),
      ],
    );
  }
}
