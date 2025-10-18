import 'package:flutter/material.dart';
import 'package:equipment_rental_system/api_service.dart';

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
    try {
      await ApiService().createMaintenanceRequest(
        name: equipmentController.text.trim(),
        message: descriptionController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("تم إرسال طلب الصيانة")));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل إرسال الطلب: $e')));
    }
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
