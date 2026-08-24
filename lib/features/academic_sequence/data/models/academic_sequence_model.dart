class AcademicYearRecord {
  final String academicYear;
  final String grade;
  final String status;
  final String rawValue;

  const AcademicYearRecord({
    required this.academicYear,
    required this.grade,
    required this.status,
    required this.rawValue,
  });
}

class AcademicStudent {
  final String studentNumber;
  final String firstName;
  final String lastName;
  final String currentGrade;
  final String section;
  final List<AcademicYearRecord> records;

  const AcademicStudent({
    required this.studentNumber,
    required this.firstName,
    required this.lastName,
    required this.currentGrade,
    required this.section,
    required this.records,
  });

  String get fullName {
    final parts = [
      firstName.trim(),
      lastName.trim(),
    ].where((e) => e.isNotEmpty).toList();

    return parts.join(' ');
  }
}
