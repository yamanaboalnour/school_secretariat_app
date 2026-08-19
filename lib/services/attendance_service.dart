import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'attendance';

  // حفظ أو تحديث حالة حضور مجموعة طلاب لليوم المحدد
  Future<void> saveDailyAttendance(List<AttendanceModel> records) async {
    final batch = _db.batch();

    for (var record in records) {
      // إنشاء معرف فريد يضمن عدم تكرار تسجيل الطالب في نفس اليوم
      String dateStr = "${record.date.year}-${record.date.month}-${record.date.day}";
      String docId = "${record.studentId}_$dateStr";

      DocumentReference docRef = _db.collection(_collectionPath).doc(docId);
      batch.set(docRef, record.toFirestore(), SetOptions(merge: true));
    }

    await batch.commit();
  }

  // جلب سجلات الحضور ليوم محدد وصف معين
  Stream<List<AttendanceModel>> getAttendanceByDateAndGrade(DateTime date, String grade) {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _db
        .collection(_collectionPath)
        .where('grade', isEqualTo: grade)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromFirestore(doc))
            .toList());
  }
}