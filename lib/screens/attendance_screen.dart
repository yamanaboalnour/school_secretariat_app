import 'package:flutter/material.dart';
import '../features/attendance/presentation/pages/attendance_page.dart';

/// Compatibility entry point for older navigation paths.
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AttendancePage();
  }
}
