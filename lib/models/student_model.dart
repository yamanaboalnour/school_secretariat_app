class Student {
  final String generalId;
  final String fullName;
  final String fatherName;
  final String motherName;
  final String birthPlace;
  final String birthDate;
  final String latestGrade;
  final String latestStatus;
  final bool isSynced; // للتأكد من المزامنة مع السحابة لاحقاً

  Student({
    required this.generalId,
    required this.fullName,
    required this.fatherName,
    required this.motherName,
    required this.birthPlace,
    required this.birthDate,
    this.latestGrade = 'غير محدد',
    this.latestStatus = 'مستجد',
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'generalId': generalId,
      'fullName': fullName,
      'fatherName': fatherName,
      'motherName': motherName,
      'birthPlace': birthPlace,
      'birthDate': birthDate,
      'latestGrade': latestGrade,
      'latestStatus': latestStatus,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      generalId: map['generalId'] ?? '',
      fullName: map['fullName'] ?? '',
      fatherName: map['fatherName'] ?? '',
      motherName: map['motherName'] ?? '',
      birthPlace: map['birthPlace'] ?? '',
      birthDate: map['birthDate'] ?? '',
      latestGrade: map['latestGrade'] ?? 'غير محدد',
      latestStatus: map['latestStatus'] ?? 'مستجد',
      isSynced: (map['isSynced'] ?? 0) == 1,
    );
  }
}