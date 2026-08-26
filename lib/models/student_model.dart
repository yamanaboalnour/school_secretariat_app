class AcademicRecord {
  final String academicYear; // مثال: "٢٠٢٣ م / ٢٠٢٤ م"
  final String grade;        // مثال: "7" أو "السابع"
  final String status;       // مثال: "ناجح"

  AcademicRecord({
    required this.academicYear,
    required this.grade,
    required this.status,
  });
}

class Student {
  final String id;
  final String fullName;
  final String fatherName;
  final String birthPlace;
  final String birthDate;
  final List<AcademicRecord> records;

  Student({
    required this.id,
    required this.fullName,
    required this.fatherName,
    required this.birthPlace,
    required this.birthDate,
    required this.records,
  });
}