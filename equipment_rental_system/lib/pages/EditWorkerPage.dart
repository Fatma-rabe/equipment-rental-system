import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditWorkerPage extends StatefulWidget {
  final String workerId;
  final Map<String, dynamic> workerData;

  const EditWorkerPage({super.key, required this.workerId, required this.workerData});

  @override
  State<EditWorkerPage> createState() => _EditWorkerPageState();
}

class _EditWorkerPageState extends State<EditWorkerPage> {
  late TextEditingController nameController;
  late TextEditingController positionController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.workerData['name']);
    positionController = TextEditingController(text: widget.workerData['position']);
    phoneController = TextEditingController(text: widget.workerData['phone']);
  }

  void updateWorker() async {
    final name = nameController.text.trim();
    final position = positionController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || position.isEmpty || phone.isEmpty) return;

    await FirebaseFirestore.instance.collection('workers').doc(widget.workerId).update({
      'name': name,
      'position': position,
      'phone': phone,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تحديث بيانات العامل')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تعديل بيانات العامل')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'الاسم'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: positionController,
              decoration: InputDecoration(labelText: 'الوظيفة'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'رقم الهاتف'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: updateWorker,
              child: Text('تحديث'),
            ),
          ],
        ),
      ),
    );
  }
}
