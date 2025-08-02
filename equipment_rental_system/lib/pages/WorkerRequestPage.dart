import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WorkerRequestPage extends StatefulWidget {
  const WorkerRequestPage({super.key});

  @override
  State<WorkerRequestPage> createState() => _WorkerRequestPageState();
}

class _WorkerRequestPageState extends State<WorkerRequestPage> {
  String? _selectedWorkerId;
  Map<String, dynamic>? _selectedWorkerData;
  int _days = 0;
  double _totalCost = 0;

  final TextEditingController _daysController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _daysController.addListener(_calculateTotal);
  }

  void _calculateTotal() {
    final days = int.tryParse(_daysController.text) ?? 0;
    final salary = _selectedWorkerData != null
        ? double.tryParse(_selectedWorkerData!['dailySalary'].toString()) ?? 0
        : 0;

    setState(() {
      _days = days;
      _totalCost = (days * salary).toDouble();
    });
  }

  Future<void> _sendRequest() async {
    if (_selectedWorkerId == null || _selectedWorkerData == null || _days <= 0) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('worker_requests').add({
      'userId': user.uid,
      'workerId': _selectedWorkerId,
      'workerName': _selectedWorkerData!['name'],
      'jobTitle': _selectedWorkerData!['jobTitle'],
      'dailySalary': _selectedWorkerData!['dailySalary'],
      'days': _days,
      'totalPrice': _totalCost, // ✅ تم التعديل هنا
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال طلب العامل بنجاح')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلب عامل')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('workers').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                final workers = snapshot.data!.docs;

                return DropdownButtonFormField<String>(
                  hint: const Text('اختر العامل'),
                  value: _selectedWorkerId,
                  items: workers.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text('${data['name']} - ${data['jobTitle']}'),
                      onTap: () {
                        setState(() {
                          _selectedWorkerData = data;
                          _calculateTotal();
                        });
                      },
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedWorkerId = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'عدد الأيام'),
            ),
            const SizedBox(height: 16),
            if (_selectedWorkerData != null) ...[
              Text('أجر اليوم: ${_selectedWorkerData!['dailySalary']} ج.م'),
              const SizedBox(height: 8),
              Text(
                'الإجمالي: ${_totalCost.toStringAsFixed(2)} ج.م',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _sendRequest,
              icon: const Icon(Icons.send),
              label: const Text('إرسال الطلب'),
            ),
          ],
        ),
      ),
    );
  }
}
