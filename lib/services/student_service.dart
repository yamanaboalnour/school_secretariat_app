import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';

class StudentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'students';

  // إضافة طالب جديد إلى قاعدة البيانات
  Future<void> addStudent(StudentModel student) async {
    await _db.collection(_collectionPath).add(student.toFirestore());
  }

  // جلب قائمة جميع الطلاب (مجرى مباشر للبيانات)
  Stream<List<StudentModel>> getAllStudents() {
    return _db
        .collection(_collectionPath)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StudentModel.fromFirestore(doc))
            .toList());
  }

  // جلب الطلاب حسب الصف (مثال: "الأول الثانوي")
  Stream<List<StudentModel>> getStudentsByGrade(String grade) {
    return _db
        .collection(_collectionPath)
        .where('grade', isEqualTo: grade)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StudentModel.fromFirestore(doc))
            .toList());
  }

  // تحديث بيانات طالب
  Future<void> updateStudent(StudentModel student) async {
    await _db
        .collection(_collectionPath)
        .doc(student.id)
        .update(student.toFirestore());
  }

  // حذف طالب
  Future<void> deleteStudent(String id) async {
    await _db.collection(_collectionPath).doc(id).delete();
  }
}