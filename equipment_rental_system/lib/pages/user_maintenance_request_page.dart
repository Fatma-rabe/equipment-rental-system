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
    if (equipmentController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("يرجى إدخال كل البيانات")));
      return;
    }

    // Placeholder: simulate sending request without Firebase
    await Future.delayed(const Duration(milliseconds: 300));

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
