import '../models/student_model.dart';
import '../helpers/db_helper.dart';

class StudentService {
  static Future<List<Student>> getStudents() async {
    final dataList = await DBHelper.getData('students');
    return dataList.map((item) => Student.fromMap(item)).toList();
  }

  static Future<void> addStudent(Student student) async {
    await DBHelper.insert('students', student.toMap());
  }

  static Future<void> updateStudent(Student student) async {
    if (student.generalId != null) {
      await DBHelper.update('students', student.toMap(), student.generalId!);
    }
  }

  static Future<void> deleteStudent(int id) async {
    await DBHelper.delete('students', id);
  }
}