import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum RentalType { perHour, perMeter }

class EditEquipmentPage extends StatefulWidget {
  final String equipmentId;
  final Map<String, dynamic> currentData;

  const EditEquipmentPage({
    required this.equipmentId,
    required this.currentData,
  });

  @override
  _EditEquipmentPageState createState() => _EditEquipmentPageState();
}

class _EditEquipmentPageState extends State<EditEquipmentPage> {
  late TextEditingController nameController;
  late TextEditingController typeController;
  late TextEditingController priceController;

  late RentalType _rentalType;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentData['name']);
    typeController = TextEditingController(text: widget.currentData['type']);
    priceController = TextEditingController(text: widget.currentData['price'].toString());

    _rentalType = widget.currentData['pricingType'] == 'meter'
        ? RentalType.perMeter
        : RentalType.perHour;
  }

  void updateEquipment() async {
    final name = nameController.text.trim();
    final type = typeController.text.trim();
    final price = double.tryParse(priceController.text.trim()) ?? 0.0;

    if (name.isEmpty || type.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("يرجى ملء جميع الحقول بشكل صحيح")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('equipment').doc(widget.equipmentId).update({
      'name': name,
      'type': type,
      'price': price,
      'pricingType': _rentalType == RentalType.perHour ? 'hour' : 'meter',
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("تعديل بيانات المعدة")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "اسم المعدة"),
            ),
            TextField(
              controller: typeController,
              decoration: InputDecoration(labelText: "النوع"),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "السعر"),
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("طريقة التأجير:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ListTile(
                  title: const Text('بالساعة'),
                  leading: Radio<RentalType>(
                    value: RentalType.perHour,
                    groupValue: _rentalType,
                    onChanged: (RentalType? value) {
                      setState(() {
                        _rentalType = value!;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('بالمتر'),
                  leading: Radio<RentalType>(
                    value: RentalType.perMeter,
                    groupValue: _rentalType,
                    onChanged: (RentalType? value) {
                      setState(() {
                        _rentalType = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: updateEquipment,
              child: Text("حفظ التعديلات"),
            ),
          ],
        ),
      ),
    );
  }
}

