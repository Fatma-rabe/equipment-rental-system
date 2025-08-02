import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddEquipmentPage extends StatefulWidget {
  const AddEquipmentPage({Key? key}) : super(key: key);

  @override
  _AddEquipmentPageState createState() => _AddEquipmentPageState();
}

class _AddEquipmentPageState extends State<AddEquipmentPage> {
  final nameController = TextEditingController();
  final typeController = TextEditingController();
  final priceController = TextEditingController();

  String pricingType = 'بالساعة';
  bool isLoading = false;
  String? errorMessage;

  void addEquipment() async {
    final name = nameController.text.trim();
    final type = typeController.text.trim();
    final price = priceController.text.trim();

    if (name.isEmpty || type.isEmpty || price.isEmpty) {
      setState(() {
        errorMessage = 'يرجى ملء جميع الحقول';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await FirebaseFirestore.instance.collection('equipment').add({
        'name': name,
        'type': type,
        'price': price,
        'pricingType': pricingType,
        'createdAt': Timestamp.now(),
      });

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        errorMessage = 'حدث خطأ أثناء الإضافة: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة معدة جديدة')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
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
                    onChanged: (value) {
                      setState(() {
                        pricingType = value!;
                      });
                    },
                  ),
                  const Text('بالساعة'),
                  Radio<String>(
                    value: 'بالمتر',
                    groupValue: pricingType,
                    onChanged: (value) {
                      setState(() {
                        pricingType = value!;
                      });
                    },
                  ),
                  const Text('بالمتر'),
                ],
              ),
              const SizedBox(height: 24),
              if (errorMessage != null)
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: addEquipment,
                child: const Text('إضافة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
