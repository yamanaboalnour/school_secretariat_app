import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/dashboard_service.dart';
import '../services/sequence_service.dart';

class DashboardScreen extends StatefulWidget {
  final List<Student> students;

  const DashboardScreen({super.key, required this.students});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalIssuedDocuments = 0;

  @override
  void initState() {
    super.initState();
    _loadIssuedCount();
  }

  Future<void> _loadIssuedCount() async {
    int nextSeq = await SequenceService.getNextSequenceNumber();
    setState(() {
      _totalIssuedDocuments = nextSeq - 1000; // الإحصاء استناداً لبداية الترقيم من 1000
    });
  }

  @override
  Widget build(BuildContext context) {
    final analytics = DashboardAnalytics.calculate(widget.students);
    const primaryGreen = Color(0xFF1B3B2B);
    const goldAccent = Color(0xFFD4AF37);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الإحصائيات والمعلومات'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. بطاقات المؤشرات السريعة (KPIs)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _buildStatCard(
                    title: 'إجمالي الطلاب',
                    value: '${analytics.totalStudents}',
                    icon: Icons.groups_rounded,
                    color: primaryGreen,
                  ),
                  _buildStatCard(
                    title: 'الوثائق المُصدرة',
                    value: '$_totalIssuedDocuments',
                    icon: Icons.print_rounded,
                    color: goldAccent,
                  ),
                  _buildStatCard(
                    title: 'نسبة النجاح العامة',
                    value: '${analytics.passRate.toStringAsFixed(1)}%',
                    icon: Icons.verified_rounded,
                    color: Colors.green.shade700,
                  ),
                  _buildStatCard(
                    title: 'الطلاب الراسبون',
                    value: '${analytics.totalFailed}',
                    icon: Icons.warning_amber_rounded,
                    color: Colors.red.shade700,
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // 2. توزيع الطلاب حسب الصفوف
              const Text(
                'توزيع الطلاب حسب الصفوف الدراسية',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: analytics.gradeDistribution.entries.map((entry) {
                      double percentage = analytics.totalStudents > 0
                          ? (entry.value / analytics.totalStudents)
                          : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('الصف ${entry.key}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('${entry.value} طالب (${(percentage * 100).toStringAsFixed(1)}%)'),
                              ],
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: Colors.grey.shade200,
                              color: primaryGreen,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}