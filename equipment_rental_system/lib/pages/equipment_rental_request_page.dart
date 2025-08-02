import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EquipmentRentalRequestPage extends StatefulWidget {
  final String equipmentId;
  final Map<String, dynamic> equipmentData;

  const EquipmentRentalRequestPage({
    Key? key,
    required this.equipmentId,
    required this.equipmentData,
  }) : super(key: key);

  @override
  State<EquipmentRentalRequestPage> createState() => _EquipmentRentalRequestPageState();
}

class _EquipmentRentalRequestPageState extends State<EquipmentRentalRequestPage> {
  String _selectedUnit = 'ساعة'; // أو 'متر'
  int _quantity = 0;
  double _totalPrice = 0;

  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_calculateTotal);
  }

  void _calculateTotal() {
    final pricePerUnit = double.tryParse(widget.equipmentData['price'].toString()) ?? 0.0;
    final quantity = int.tryParse(_quantityController.text) ?? 0;

    setState(() {
      _quantity = quantity;
      _totalPrice = quantity * pricePerUnit;
    });
  }

  Future<void> _sendRentalRequest() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('equipment_requests').add({
      'userId': user.uid,
      'equipmentId': widget.equipmentId,
      'equipmentName': widget.equipmentData['name'],
      'unit': _selectedUnit,
      'quantity': _quantity,
      'price': widget.equipmentData['price'],
      'totalPrice': _totalPrice,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إرسال طلب الإيجار بنجاح')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.equipmentData['price'];

    return Scaffold(
      appBar: AppBar(title: Text('طلب تأجير ${widget.equipmentData['name']}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedUnit,
              items: ['ساعة', 'متر'].map((unit) {
                return DropdownMenuItem(value: unit, child: Text(unit));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUnit = value!;
                });
              },
              decoration: InputDecoration(labelText: 'الوحدة'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'الكمية ($_selectedUnit)'),
            ),
            SizedBox(height: 16),
            Text('سعر الوحدة: $price ج.م'),
            SizedBox(height: 8),
            Text('الإجمالي: ${_totalPrice.toStringAsFixed(2)} ج.م', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Spacer(),
            ElevatedButton.icon(
              onPressed: _sendRentalRequest,
              icon: Icon(Icons.send),
              label: Text('إرسال الطلب'),
            ),
          ],
        ),
      ),
    );
  }
}
