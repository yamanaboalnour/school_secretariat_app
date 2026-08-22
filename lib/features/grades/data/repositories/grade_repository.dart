import 'package:sqflite/sqflite.dart';

import '../../../../database/database_helper.dart';
import '../models/grade_model.dart';

class GradeRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> saveGrade(GradeModel grade) async {
    final database = await _databaseHelper.database;
    return database.insert(
      'grades',
      grade.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<GradeModel>> getStudentGrades(int studentId) async {
    final database = await _databaseHelper.database;
    final rows = await database.query(
      'grades',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'subject_name COLLATE NOCASE ASC',
    );
    return rows.map(GradeModel.fromMap).toList();
  }

  Future<int> deleteGrade(int id) async {
    final database = await _databaseHelper.database;
    return database.delete('grades', where: 'id = ?', whereArgs: [id]);
  }
}
