import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddWorkerPage extends StatefulWidget {
  const AddWorkerPage({super.key});

  @override
  State<AddWorkerPage> createState() => _AddWorkerPageState();
}

class _AddWorkerPageState extends State<AddWorkerPage> {
  final nameController = TextEditingController();
  final jobTitleController = TextEditingController();
  final phoneController = TextEditingController();
  final salaryController = TextEditingController();
  final notesController = TextEditingController();

  void saveWorker() async {
    if (nameController.text.isEmpty || salaryController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('workers').add({
      'name': nameController.text.trim(),
      'jobTitle': jobTitleController.text.trim(),
      'phone': phoneController.text.trim(),
      'dailySalary': double.tryParse(salaryController.text.trim()) ?? 0,
      'notes': notesController.text.trim(),
      'createdAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إضافة العامل بنجاح')),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    jobTitleController.dispose();
    phoneController.dispose();
    salaryController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إضافة عامل')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'اسم العامل')),
              TextField(controller: jobTitleController, decoration: InputDecoration(labelText: 'الوظيفة')),
              TextField(controller: phoneController, decoration: InputDecoration(labelText: 'رقم الهاتف')),
              TextField(controller: salaryController, decoration: InputDecoration(labelText: 'الراتب اليومي'), keyboardType: TextInputType.number),
              TextField(controller: notesController, decoration: InputDecoration(labelText: 'ملاحظات'), maxLines: 2),
              SizedBox(height: 24),
              ElevatedButton(onPressed: saveWorker, child: Text('حفظ')),
            ],
          ),
        ),
      ),
    );
  }
}
