import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'EditWorkerPage.dart';
import 'add_worker_page.dart';


class AdminWorkersPage extends StatelessWidget {
  const AdminWorkersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إدارة العمال')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('workers').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final workers = snapshot.data!.docs;

          if (workers.isEmpty) {
            return Center(child: Text('لا يوجد عمال حالياً'));
          }

          return ListView.builder(
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final worker = workers[index];
              final data = worker.data() as Map<String, dynamic>;

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
                            builder: (context) => EditWorkerPage(workerId: worker.id, workerData: {},),
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
                          await FirebaseFirestore.instance
                              .collection('workers')
                              .doc(worker.id)
                              .delete();
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
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
