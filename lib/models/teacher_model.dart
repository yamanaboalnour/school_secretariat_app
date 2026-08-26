import 'package:cloud_firestore/cloud_firestore.dart';

enum TeacherRole { admin, secretary, teacher }

class TeacherModel {
  final String id;
  final String fullName;
  final String subject; // المادة المدرسة (مثل: رياضيات، فيزياء)
  final String phone;
  final String email;
  final TeacherRole role; // دور المستخدم وصلاحياته
  final int weeklyClasses; // النصاب الأسبوعي للحصص
  final DateTime createdAt;

  TeacherModel({
    required this.id,
    required this.fullName,
    required this.subject,
    required this.phone,
    required this.email,
    required this.role,
    required this.weeklyClasses,
    required this.createdAt,
  });

  factory TeacherModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TeacherModel(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      subject: data['subject'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      role: _stringToRole(data['role']),
      weeklyClasses: data['weeklyClasses'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'subject': subject,
      'phone': phone,
      'email': email,
      'role': role.name,
      'weeklyClasses': weeklyClasses,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static TeacherRole _stringToRole(String? roleStr) {
    switch (roleStr) {
      case 'admin':
        return TeacherRole.admin;
      case 'secretary':
        return TeacherRole.secretary;
      default:
        return TeacherRole.teacher;
    }
  }
}
