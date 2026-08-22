import '../../../../core/database/database_helper.dart';
import '../models/student_model.dart';

class StudentRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertStudent(StudentModel student) async {
    final db = await _dbHelper.database;
    return await db.insert('students', student.toMap());
  }

  Future<List<StudentModel>> getStudents({String query = ''}) async {
    final db = await _dbHelper.database;
    List<Map<String, dynamic>> maps;

    if (query.isEmpty) {
      maps = await db.query('students', orderBy: 'id DESC');
    } else {
      maps = await db.query(
        'students',
        where: 'first_name LIKE ? OR last_name LIKE ? OR father_name LIKE ? OR national_id LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
        orderBy: 'id DESC',
      );
    }

    return List.generate(maps.length, (i) => StudentModel.fromMap(maps[i]));
  }

  Future<int> deleteStudent(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }
}