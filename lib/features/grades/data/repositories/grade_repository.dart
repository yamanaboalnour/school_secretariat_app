import 'package:sqflite/sqflite.dart';
import 'dart:convert';

import '../../../../database/database_helper.dart';
import '../models/grade_model.dart';

class GradeRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> saveGrade(GradeModel grade) async {
    final database = await _databaseHelper.database;
    return database.transaction((transaction) async {
      final values = grade.toMap()..remove('id');
      final id = await transaction.insert(
        'grades',
        values,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await transaction.insert('sync_queue', {
        'entity_type': 'grade',
        'entity_id': '${grade.studentId}_${grade.subjectName}',
        'operation': 'upsert',
        'payload': jsonEncode({...values, 'id': id}),
        'status': 'pending',
        'attempts': 0,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
      return id;
    });
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
