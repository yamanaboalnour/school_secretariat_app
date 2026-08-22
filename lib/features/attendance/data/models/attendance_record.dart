enum AttendanceStatus { present, absent, excused, late }

class AttendanceRecord {
  final int? id;
  final int studentId;
  final String attendanceDate;
  final AttendanceStatus status;
  final String? note;

  const AttendanceRecord({
    this.id,
    required this.studentId,
    required this.attendanceDate,
    required this.status,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'attendance_date': attendanceDate,
      'status': status.name,
      'note': note,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] as int?,
      studentId: map['student_id'] as int,
      attendanceDate: map['attendance_date'] as String,
      status: AttendanceStatus.values.firstWhere(
        (value) => value.name == map['status'],
        orElse: () => AttendanceStatus.present,
      ),
      note: map['note'] as String?,
    );
  }
}
