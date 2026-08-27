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
  final String fatherName;
  final String birthPlace;
  final String birthDate;
  final String currentGrade;
  final String section;

  final List<AcademicYearRecord> records;

  const AcademicStudent({
    required this.studentNumber,
    required this.firstName,
    required this.lastName,
    required this.fatherName,
    required this.birthPlace,
    required this.birthDate,
    required this.currentGrade,
    required this.section,
    required this.records,
  });

  String get fullName {
    return [
      firstName.trim(),
      lastName.trim(),
    ].where((value) => value.isNotEmpty).join(' ');
  }

  String get fullNameWithFather {
    return [
      fullName,
      fatherName.trim(),
    ].where((value) => value.isNotEmpty).join(' ');
  }
}
