import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MaintenanceRequestPage extends StatefulWidget {
  const MaintenanceRequestPage({super.key});

  @override
  State<MaintenanceRequestPage> createState() => _MaintenanceRequestPageState();
}

class _MaintenanceRequestPageState extends State<MaintenanceRequestPage> {
  final equipmentController = TextEditingController();
  final descriptionController = TextEditingController();

  void sendRequest() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (equipmentController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("يرجى إدخال كل البيانات")));
      return;
    }

    await FirebaseFirestore.instance.collection('maintenance_requests').add({
      'userId': userId,
      'equipmentName': equipmentController.text.trim(),
      'description': descriptionController.text.trim(),
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("تم إرسال طلب الصيانة")));

    Navigator.pop(context);
  }

  @override
  void dispose() {
    equipmentController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("طلب صيانة")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: equipmentController,
              decoration: InputDecoration(labelText: "اسم المعدة"),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: "وصف المشكلة"),
              maxLines: 4,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: sendRequest,
              child: Text("إرسال الطلب"),
            ),
          ],
        ),
      ),
    );
  }
}
