import 'package:cloud_firestore/cloud_firestore.dart';

class GradeModel {
  final String id;
  final String studentId;
  final String studentName;
  final String subject; // اسم المادة
  final String term; // الفصل الدراسي (الفصل الأول / الفصل الثاني)
  final double examScore; // درجة الامتحان
  final double activityScore; // درجة النشاط/المذاكرة
  final double maxScore; // الدرجة العظمى للمادة

  GradeModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.subject,
    required this.term,
    required this.examScore,
    required this.activityScore,
    required this.maxScore,
  });

  // حساب المجموع الكلي للمادة
  double get totalScore => examScore + activityScore;

  factory GradeModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GradeModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      subject: data['subject'] ?? '',
      term: data['term'] ?? 'الفصل الأول',
      examScore: (data['examScore'] as num?)?.toDouble() ?? 0.0,
      activityScore: (data['activityScore'] as num?)?.toDouble() ?? 0.0,
      maxScore: (data['maxScore'] as num?)?.toDouble() ?? 100.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'subject': subject,
      'term': term,
      'examScore': examScore,
      'activityScore': activityScore,
      'maxScore': maxScore,
    };
  }
}
