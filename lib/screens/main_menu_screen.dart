import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../models/sequence_log_model.dart';
import '../services/student_service.dart';
import 'students_list_screen.dart';
import 'dashboard_screen.dart';
import 'sequence_log_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  List<Student> _students = [];
  List<SequenceLog> _sequenceLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedStudents = await StudentService.loadStudentsFromCsv();
    setState(() {
      _students = loadedStudents;
      _isLoading = false;
    });
  }

  // دالة توثيق التسلسل وإضافته إلى الأرشيف
  void _addSequenceLog(Student student) {
    setState(() {
      _sequenceLogs.add(
        SequenceLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          studentName: student.fullName,
          generalId: student.generalId,
          generatedAt: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B3B2B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('أمانة سر الثانوية'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildMenuButton(
                      context,
                      title: 'السجل العام للطلاب',
                      icon: Icons.people_alt_rounded,
                      color: primaryGreen,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentsListScreen(
                              students: _students,
                              onGenerateSequence: _addSequenceLog,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildMenuButton(
                      context,
                      title: 'لوحة الإحصائيات',
                      icon: Icons.dashboard_rounded,
                      color: primaryGreen,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DashboardScreen(students: _students),
                          ),
                        );
                      },
                    ),
                    _buildMenuButton(
                      context,
                      title: 'سجل التسلسل الدراسي',
                      icon: Icons.history_edu_rounded,
                      color: primaryGreen,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SequenceLogScreen(logs: _sequenceLogs),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}