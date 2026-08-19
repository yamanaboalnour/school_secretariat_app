import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/csv_service.dart';
import 'dashboard_screen.dart';
import 'general_register_screen.dart';
import 'academic_sequence_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  List<Student> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final studentsData = await CsvService.loadStudentsData();
      setState(() {
        _students = studentsData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء تحميل البيانات: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B3B2B);
    const goldAccent = Color(0xFFD4AF37);

    return Scaffold(
      appBar: AppBar(
        title: const Text('أمانة السر - القائمة الرئيسية'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey.shade100,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // ترويسة الشاشة الرئيسية
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.school, color: goldAccent, size: 40),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'ثانوية الشيخ المربي عبد الكريم الرفاعي',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'الشرعية للبنين - نظام أمانة السر الرقمي',
                                    style: TextStyle(
                                      color: goldAccent,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // 1. بطاقة لوحة الإحصائيات والمعلومات
                      _buildMenuCard(
                        title: 'لوحة الإحصائيات والمعلومات',
                        subtitle: 'ملخص شامل لأعداد الطلاب، نسب النجاح والوثائق',
                        icon: Icons.dashboard_rounded,
                        iconColor: primaryGreen,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DashboardScreen(students: _students),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 15),

                      // 2. بطاقة السجل العام للطالب
                      _buildMenuCard(
                        title: 'السجل العام للطلاب',
                        subtitle: 'عرض كامل ملفات الطلاب والبحث في السجل العام',
                        icon: Icons.menu_book_rounded,
                        iconColor: primaryGreen,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GeneralRegisterScreen(students: _students),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 15),

                      // 3. بطاقة سجل التسلسل الدراسي
                      _buildMenuCard(
                        title: 'سجل التسلسل الدراسي',
                        subtitle: 'إصدار وطباعة وثائق التسلسل الدراسي الرسمية',
                        icon: Icons.description_rounded,
                        iconColor: primaryGreen,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AcademicSequenceScreen(students: _students),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    const goldAccent = Color(0xFFD4AF37);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: goldAccent.withOpacity(0.3), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B3B2B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}