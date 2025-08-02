import 'package:equipment_rental_system/pages/user_chat_page.dart';
import 'package:equipment_rental_system/pages/user_maintenance_request_page.dart';
import 'package:flutter/material.dart';
import 'WorkerRequestPage.dart';
import 'user_item_request_page.dart';
import 'package:equipment_rental_system/pages/equipment_page.dart'; // ← تأكد من وجود هذا الملف

class UserDashboardPage extends StatelessWidget {
  const UserDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الصفحة الرئيسية للمستخدم'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            DashboardCard(
              title: "طلب صنف من المخزن",
              icon: Icons.add_shopping_cart,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RequestItemPage()),
                );
              },
            ),
            DashboardCard(
              title: "طلب صيانة",
              icon: Icons.build_circle,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MaintenanceRequestPage()),
                );
              },
            ),
            DashboardCard(
              title: "مراسلة الأدمن",
              icon: Icons.chat,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserChatPage()),
                );
              },
            ),

            DashboardCard(
              title: "طلب معدة",
              icon: Icons.build,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EquipmentPage()),
                );
              },
            ),
            DashboardCard(
              title: "طلب عمال",
              icon: Icons.people_alt,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WorkerRequestPage()),
                );
              },
            ),

            // كروت تانية ممكن تتضاف هنا
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
              Icon(icon, size: 48, color: Colors.green),
              SizedBox(height: 12),
              Text(title, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
