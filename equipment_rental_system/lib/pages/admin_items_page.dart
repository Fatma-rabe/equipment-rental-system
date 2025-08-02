import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminItemsPage extends StatelessWidget {
  const AdminItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إدارة المخزن")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('items').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("لا يوجد أصناف حالياً"));
          }

          final items = snapshot.data!.docs;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final data = item.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['name'] ?? ''),
                subtitle: Text("الكمية: ${data['quantity']} - السعر: ${data['price']}/وحدة"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => EditItemDialog(itemId: item.id, currentData: data),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
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
                          await FirebaseFirestore.instance
                              .collection('items')
                              .doc(item.id)
                              .delete();
                        }
                      },
                    ),
                  ],
                ),

              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddItemDialog(),
          );
        },
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
      await FirebaseFirestore.instance.collection('items').add({
        'name': name,
        'quantity': quantity,
        'price': price,
        'createdAt': Timestamp.now(),
      });
      Navigator.pop(context);
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
    await FirebaseFirestore.instance.collection('items').doc(widget.itemId).update({
      'name': nameController.text.trim(),
      'quantity': int.tryParse(quantityController.text.trim()) ?? 0,
      'price': double.tryParse(priceController.text.trim()) ?? 0.0,
    });
    Navigator.pop(context);
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
