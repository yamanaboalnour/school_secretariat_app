import 'package:flutter/material.dart';

/// Compatibility entry point kept until attendance is migrated to local SQLite.
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الحضور والغياب اليومي')),
      body: const Center(
        child: Text('سيتم تفعيل سجل الحضور ضمن قاعدة البيانات المحلية.'),
      ),
    );
  }
}
