import 'package:flutter/material.dart';
import '../screens/students_screen.dart';
import '../screens/teachers_screen.dart';
import '../screens/attendance_screen.dart'; // تم إضافة استدعاء شاشة الحضور والغياب
import '../screens/grades_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.indigo),
            accountName: const Text(
              'أمانة السر الثانوية',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: const Text('المستخدم الحالي: أمين السر'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.school, size: 40, color: Colors.indigo.shade800),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.indigo),
            title: const Text('سجل الطلاب'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const StudentsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.badge, color: Colors.teal),
            title: const Text('سجل المدرسين والكادر'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const TeachersScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.how_to_reg, color: Colors.amber),
            title: const Text('الحضور والغياب اليومي'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AttendanceScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('تسجيل الخروج'),
            onTap: () {
              // سيتم ربطه بشاشة تسجيل الدخول لاحقاً
              Navigator.pop(context);
            },
          ),
          ListTile(
  leading: const Icon(Icons.grade, color: Colors.purple),
  title: const Text('كشوفات العلامات والجلاءات'),
  onTap: () {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GradesScreen()),
    );
  },
),
        ],
      ),
    );
  }
}