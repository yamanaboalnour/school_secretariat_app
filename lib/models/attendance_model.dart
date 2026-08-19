import 'package:cloud_firestore/cloud_firestore.dart';

enum AttendanceStatus { present, absent, excused, late }

class AttendanceModel {
  final String id;
  final String studentId;
  final String studentName;
  final String grade;
  final String section;
  final DateTime date;
  final AttendanceStatus status; // حاضر، غائب، بعذر، متأخر
  final String? note;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.grade,
    required this.section,
    required this.date,
    required this.status,
    this.note,
  });

  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AttendanceModel(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      grade: data['grade'] ?? '',
      section: data['section'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      status: _stringToStatus(data['status']),
      note: data['note'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'grade': grade,
      'section': section,
      'date': Timestamp.fromDate(date),
      'status': status.name,
      'note': note,
    };
  }

  static AttendanceStatus _stringToStatus(String? statusStr) {
    switch (statusStr) {
      case 'absent':
        return AttendanceStatus.absent;
      case 'excused':
        return AttendanceStatus.excused;
      case 'late':
        return AttendanceStatus.late;
      default:
        return AttendanceStatus.present;
    }
  }
}