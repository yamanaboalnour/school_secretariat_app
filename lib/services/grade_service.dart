import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/grade_model.dart';

class GradeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'grades';

  // إضافة أو تحديث علامة طالب لمادة معينة
  Future<void> saveGrade(GradeModel grade) async {
    String docId = "${grade.studentId}_${grade.subject}_${grade.term}";
    await _db
        .collection(_collectionPath)
        .doc(docId)
        .set(grade.toFirestore(), SetOptions(merge: true));
  }

  // جلب كافة علامات طالب معين لطباعة الجلاء
  Stream<List<GradeModel>> getStudentGrades(String studentId, String term) {
    return _db
        .collection(_collectionPath)
        .where('studentId', isEqualTo: studentId)
        .where('term', isEqualTo: term)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GradeModel.fromFirestore(doc))
            .toList());
  }
}