class GradeModel {
  final int? id;
  final int studentId;
  final String subjectName;
  final double firstTerm;
  final double secondTerm;

  const GradeModel({
    this.id,
    required this.studentId,
    required this.subjectName,
    required this.firstTerm,
    required this.secondTerm,
  });

  double get total => firstTerm + secondTerm;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'subject_name': subjectName,
      'first_term': firstTerm,
      'second_term': secondTerm,
    };
  }

  factory GradeModel.fromMap(Map<String, dynamic> map) {
    return GradeModel(
      id: map['id'] as int?,
      studentId: map['student_id'] as int,
      subjectName: map['subject_name'] as String? ?? '',
      firstTerm: (map['first_term'] as num?)?.toDouble() ?? 0,
      secondTerm: (map['second_term'] as num?)?.toDouble() ?? 0,
    );
  }
}
