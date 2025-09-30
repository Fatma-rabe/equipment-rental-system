import 'package:flutter/material.dart';

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
    if (selectedItemId == null || quantityController.text.isEmpty) return;

    // Placeholder: simulate sending request without Firebase
    await Future.delayed(const Duration(milliseconds: 300));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إرسال الطلب بنجاح')),
    );

    Navigator.pop(context);
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
        child: Column(
          children: [
            // Placeholder dropdown without Firebase: use a static list
            Builder(builder: (context) {
              final items = [
                {'id': 'a', 'name': 'صنف 1', 'price': 50},
                {'id': 'b', 'name': 'صنف 2', 'price': 80},
              ];

              return DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'اختر الصنف'),
                value: selectedItemId,
                items: items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item['id'] as String,
                    child: Text(item['name'].toString()),
                    onTap: () {
                      selectedItemData = {
                        'name': item['name'],
                        'price': item['price'],
                      } as Map<String, dynamic>;
                    },
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedItemId = value;
                    calculateTotal();
                  });
                },
              );
            }),
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
