import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
    final price = selectedItemData!['price'];
    final name = selectedItemData!['name'];
    final userId = FirebaseAuth.instance.currentUser?.uid;

    await FirebaseFirestore.instance.collection('item_requests').add({
      'userId': userId,
      'itemId': selectedItemId,
      'itemName': name,
      'quantity': quantity,
      'unitPrice': price,
      'totalPrice': totalPrice,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });

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
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('items').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();

                final items = snapshot.data!.docs;

                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'اختر الصنف'),
                  value: selectedItemId,
                  items: items.map((item) {
                    final data = item.data() as Map<String, dynamic>;
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text(data['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    final item = items.firstWhere((e) => e.id == value);
                    setState(() {
                      selectedItemId = value;
                      selectedItemData = item.data() as Map<String, dynamic>;
                      calculateTotal();
                    });
                  },
                );
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
