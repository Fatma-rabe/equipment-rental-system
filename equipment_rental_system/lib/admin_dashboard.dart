import 'package:equipment_rental_system/pages/%D9%90AdminFinancialReport.dart';
import 'package:equipment_rental_system/pages/AdminEquipmentRequests.dart';
import 'package:equipment_rental_system/pages/AdminMaintenanceRequestsPage.dart';
import 'package:equipment_rental_system/pages/AdminWorkerRequestsPage.dart';
import 'package:equipment_rental_system/pages/AdminWorkersPage.dart';
import 'package:equipment_rental_system/pages/admin_chat_page.dart';
import 'package:flutter/material.dart';
import 'package:equipment_rental_system/pages/admin_items_page.dart';
import 'package:equipment_rental_system/pages/equipment_page.dart'; // ← صفحة المعدات
import 'package:equipment_rental_system/pages/admin_item_requests_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('لوحة التحكم - الأدمن'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            DashboardCard(
              title: "إدارة المعدات",
              icon: Icons.build,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EquipmentPage()),
                );
              },
            ),

            DashboardCard(
              title: "المخزن",
              icon: Icons.store,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminItemsPage()),
                );
              },
            ),
            DashboardCard(
              title: "طلبات المخزن",
              icon: Icons.receipt_long,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminItemRequestsPage()),
                );
              },
            ),
            DashboardCard(
              title: "العمال",
              icon: Icons.people,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminWorkersPage()),
                );
              },
            ),


            DashboardCard(
              title: "طلبات الصيانة",
              icon: Icons.build,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminMaintenanceRequestsPage()),
                );
              },
            ),
            DashboardCard(
              title: "التقرير المالي",
              icon: Icons.bar_chart,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminFinancialReportPage()),
                );
              },
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminEquipmentRequestsPage()),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.construction, size: 40, color: Colors.orange),
                      SizedBox(height: 10),
                      Text('طلبات تأجير المعدات', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),

            DashboardCard(
              title: "طلبات العمال",
              icon: Icons.group,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminWorkerRequestsPage()),
                );
              },
            ),

            DashboardCard(
              title: "المحادثات",
              icon: Icons.message,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminChatPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const DashboardCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.blue),
              SizedBox(height: 12),
              Text(title, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
