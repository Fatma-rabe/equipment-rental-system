import 'package:flutter/material.dart';
import 'add_equipment_page.dart';
import 'edit_equipment_page.dart';
import 'equipment_rental_request_page.dart'; // تأكد من وجود هذا الملف

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({Key? key}) : super(key: key);

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  bool _isAdmin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    // Placeholder: no auth, treat as non-admin
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      _isAdmin = false;
      _isLoading = false;
    });
  }

  void deleteEquipment(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد أنك تريد حذف هذه المعدة؟'),
        actions: [
          TextButton(
            child: Text('إلغاء'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text('حذف', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Placeholder: simulate delete without Firebase
      await Future.delayed(const Duration(milliseconds: 200));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم حذف المعدة بنجاح')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('قائمة المعدات')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Builder(builder: (context) {
        // Placeholder static list without Firebase
        final equipmentList = [
          {'id': 'e1', 'name': 'حفار', 'type': 'ثقيل', 'price': 200, 'unit': 'ساعة'},
          {'id': 'e2', 'name': 'ونش', 'type': 'رفع', 'price': 150, 'unit': 'ساعة'},
        ];

        if (equipmentList.isEmpty) {
          return Center(child: Text('لا توجد معدات حالياً'));
        }

        return ListView.builder(
          itemCount: equipmentList.length,
          itemBuilder: (context, index) {
            final data = equipmentList[index] as Map<String, dynamic>;
            final id = data['id'] as String;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'] ?? '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      Text('النوع: ${data['type'] ?? ''}'),
                      Text('السعر: ${data['price'] ?? ''}'),
                      Text('الوحدة: ${data['unit'] ?? ''}'),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _isAdmin
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditEquipmentPage(
                                      equipmentId: id,
                                      currentData: data,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteEquipment(context, id),
                            ),
                          ],
                        )
                            : ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EquipmentRentalRequestPage(
                                  equipmentId: id,
                                  equipmentData: data,
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.request_page),
                          label: Text('طلب الإيجار'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      floatingActionButton: (!_isLoading && _isAdmin)
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEquipmentPage()),
          );
        },
        child: Icon(Icons.add),
      )
          : null,
    );
  }
}
