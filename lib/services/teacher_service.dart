import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teacher_model.dart';

class TeacherService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'teachers';

  // إضافة مدرس أو إداري جديد
  Future<void> addTeacher(TeacherModel teacher) async {
    await _db.collection(_collectionPath).add(teacher.toFirestore());
  }

  // جلب كافة المدرسين
  Stream<List<TeacherModel>> getAllTeachers() {
    return _db.collection(_collectionPath).orderBy('fullName').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => TeacherModel.fromFirestore(doc))
            .toList());
  }

  // تحديث بيانات مدرس
  Future<void> updateTeacher(TeacherModel teacher) async {
    await _db
        .collection(_collectionPath)
        .doc(teacher.id)
        .update(teacher.toFirestore());
  }

  // حذف مدرس
  Future<void> deleteTeacher(String id) async {
    await _db.collection(_collectionPath).doc(id).delete();
  }
}
