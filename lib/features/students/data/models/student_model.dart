class StudentModel {
  final int? id;
  final String firstName;
  final String lastName;
  final String fatherName;
  final String motherName;
  final String? nationalId;
  final String? birthDate;
  final String gradeLevel;
  final String registrationDate;
  final String createdAt;

  StudentModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.fatherName,
    required this.motherName,
    this.nationalId,
    this.birthDate,
    required this.gradeLevel,
    required this.registrationDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'father_name': fatherName,
      'mother_name': motherName,
      'national_id': nationalId,
      'birth_date': birthDate,
      'grade_level': gradeLevel,
      'registration_date': registrationDate,
      'created_at': createdAt,
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      fatherName: map['father_name'],
      motherName: map['mother_name'],
      nationalId: map['national_id'],
      birthDate: map['birth_date'],
      gradeLevel: map['grade_level'],
      registrationDate: map['registration_date'],
      createdAt: map['created_at'],
    );
  }
}
