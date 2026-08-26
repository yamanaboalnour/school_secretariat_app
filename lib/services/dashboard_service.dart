import '../models/student_model.dart';

class DashboardAnalytics {
  final int totalStudents;
  final Map<String, int> gradeDistribution;
  final int totalPassed;
  final int totalFailed;
  final double passRate;

  DashboardAnalytics({
    required this.totalStudents,
    required this.gradeDistribution,
    required this.totalPassed,
    required this.totalFailed,
    required this.passRate,
  });

  factory DashboardAnalytics.calculate(List<Student> students) {
    int passed = 0;
    int failed = 0;
    Map<String, int> distribution = {
      'السابع': 0,
      'الثامن': 0,
      'التاسع': 0,
      'العاشر': 0,
      'الحادي عشر': 0,
      'الثاني عشر': 0,
    };

    for (var student in students) {
      // إحصاء الصفوف
      String grade = student.latestGrade;
      if (distribution.containsKey(grade)) {
        distribution[grade] = distribution[grade]! + 1;
      }

      // إحصاء النجاح والرسوب في آخر سنة
      String status = student.latestStatus;
      if (status.contains('ناجح')) {
        passed++;
      } else if (status.contains('راسب')) {
        failed++;
      }
    }

    int totalEvaluated = passed + failed;
    double rate = totalEvaluated > 0 ? (passed / totalEvaluated) * 100 : 0.0;

    return DashboardAnalytics(
      totalStudents: students.length,
      gradeDistribution: distribution,
      totalPassed: passed,
      totalFailed: failed,
      passRate: rate,
    );
  }
}
