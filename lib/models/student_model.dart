class Student {
  final String generalId;
  final String fullName;
  final String fatherName;
  final String motherName;
  final String birthPlace;
  final String birthDate;
  final String latestGrade;
  final String latestStatus;
  final Map<String, String> academicHistory;

  Student({
    required this.generalId,
    required this.fullName,
    required this.fatherName,
    required this.motherName,
    required this.birthPlace,
    required this.birthDate,
    required this.latestGrade,
    required this.latestStatus,
    required this.academicHistory,
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      generalId: map['generalId'] ?? '',
      fullName: map['fullName'] ?? '',
      fatherName: map['fatherName'] ?? '',
      motherName: map['motherName'] ?? '',
      birthPlace: map['birthPlace'] ?? '',
      birthDate: map['birthDate'] ?? '',
      latestGrade: map['latestGrade'] ?? '',
      latestStatus: map['latestStatus'] ?? '',
      academicHistory: Map<String, String>.from(map['academicHistory'] ?? {}),
    );
  }
}