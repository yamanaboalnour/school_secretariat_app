import '../models/student_model.dart';

class StudentService {
  static Future<List<Student>> loadStudentsFromCsv() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Student(
        generalId: '1001',
        fullName: 'أحمد محمد علي',
        fatherName: 'محمد',
        motherName: 'فاطمة',
        birthPlace: 'دمشق',
        birthDate: '2008-05-15',
        latestGrade: 'الأول الثانوي',
        latestStatus: 'ناجح',
        academicHistory: {
          '2023-2024': 'السابع الأساسي - ناجح',
          '2024-2025': 'الثامن الأساسي - ناجح',
          '2025-2026': 'الأول الثانوي - مستجد',
        },
      ),
      Student(
        generalId: '1002',
        fullName: 'عمر خالد الحمصي',
        fatherName: 'خالد',
        motherName: 'عائشة',
        birthPlace: 'حمص',
        birthDate: '2007-09-20',
        latestGrade: 'الثاني الثانوي',
        latestStatus: 'ناجح',
        academicHistory: {
          '2024-2025': 'الأول الثانوي - ناجح',
          '2025-2026': 'الثاني الثانوي - مستجد',
        },
      ),
    ];
  }
}