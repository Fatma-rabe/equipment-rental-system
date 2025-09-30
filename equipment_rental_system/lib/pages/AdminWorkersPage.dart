import 'package:flutter/material.dart';
import 'EditWorkerPage.dart';
import 'add_worker_page.dart';


class AdminWorkersPage extends StatelessWidget {
  const AdminWorkersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إدارة العمال')),
      body: Builder(builder: (context) {
        // Placeholder static workers list without Firebase
        final workers = [
          {'id': 'w1', 'name': 'عامل 1', 'jobTitle': 'نجار', 'dailySalary': 100},
          {'id': 'w2', 'name': 'عامل 2', 'jobTitle': 'حداد', 'dailySalary': 120},
        ];

        if (workers.isEmpty) {
          return Center(child: Text('لا يوجد عمال حالياً'));
        }

        return ListView.builder(
          itemCount: workers.length,
          itemBuilder: (context, index) {
            final worker = workers[index];
            final data = worker as Map<String, dynamic>;

              return ListTile(
                title: Text(data['name'] ?? ''),
                subtitle: Text(data['jobTitle'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${data['dailySalary']} ج.م'),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditWorkerPage(workerId: data['id'] as String, workerData: data),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('تأكيد الحذف'),
                            content: Text('هل أنت متأكد أنك تريد حذف هذا العامل؟'),
                            actions: [
                              TextButton(
                                child: Text('إلغاء'),
                                onPressed: () => Navigator.pop(context, false),
                              ),
                              TextButton(
                                child: Text('حذف'),
                                onPressed: () => Navigator.pop(context, true),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          // Placeholder: simulate delete
                          await Future.delayed(const Duration(milliseconds: 200));
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddWorkerPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
