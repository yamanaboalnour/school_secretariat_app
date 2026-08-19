class Student {
  final String generalId; // الرقم العام
  final String fullName; // الاسم الكامل
  final String fatherName; // اسم الأب
  final String motherName; // اسم الأم
  final String birthPlace; // مكان الولادة
  final String birthDate; // تاريخ الميلاد
  final Map<String, String> academicHistory; // السجل الدراسي: {"2022/2023": "ناجح / 10"}

  Student({
    required this.generalId,
    required this.fullName,
    required this.fatherName,
    required this.motherName,
    required this.birthPlace,
    required this.birthDate,
    required this.academicHistory,
  });

  // الحصول على أحدث صف مسجل فيه الطالب
  String get latestGrade {
    if (academicHistory.isEmpty) return 'غير محدد';
    final lastEntry = academicHistory.entries.last.value;
    final parts = lastEntry.split('/');
    if (parts.length > 1) {
      return _formatGrade(parts[1].trim());
    }
    return 'غير محدد';
  }

  // الحصول على أحدث حالة للنجاح أو الرسوب
  String get latestStatus {
    if (academicHistory.isEmpty) return 'غير محدد';
    final lastEntry = academicHistory.entries.last.value;
    return lastEntry.split('/')[0].trim();
  }

  static String _formatGrade(String grade) {
    switch (grade) {
      case '7': return 'السابع';
      case '8': return 'الثامن';
      case '9': return 'التاسع';
      case '10': return 'العاشر';
      case '11': return 'الحادي عشر';
      case '12': return 'الثاني عشر';
      default: return grade;
    }
  }

  // تحويل البيانات إلى Map لمعالجة CRUD والتصدير
  Map<String, dynamic> toMap() {
    return {
      'generalId': generalId,
      'fullName': fullName,
      'fatherName': fatherName,
      'motherName': motherName,
      'birthPlace': birthPlace,
      'birthDate': birthDate,
      'academicHistory': academicHistory,
    };
  }
}