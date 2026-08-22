import 'dart:convert';

import '../../../../database/database_helper.dart';
import '../models/student_model.dart';

class StudentRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertStudent(StudentModel student) async {
    final db = await _dbHelper.database;
    return db.transaction((transaction) async {
      final id = await transaction.insert('students', student.toMap());
      await transaction.insert('sync_queue', {
        'entity_type': 'student',
        'entity_id': id.toString(),
        'operation': 'upsert',
        'payload': jsonEncode({...student.toMap(), 'id': id}),
        'status': 'pending',
        'attempts': 0,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
      return id;
    });
  }

  Future<List<StudentModel>> getStudents({String query = ''}) async {
    final db = await _dbHelper.database;
    List<Map<String, dynamic>> maps;

    if (query.isEmpty) {
      maps = await db.query('students', orderBy: 'id DESC');
    } else {
      maps = await db.query(
        'students',
        where:
            'first_name LIKE ? OR last_name LIKE ? OR father_name LIKE ? OR national_id LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
        orderBy: 'id DESC',
      );
    }

    return List.generate(maps.length, (i) => StudentModel.fromMap(maps[i]));
  }

  Future<int> deleteStudent(int id) async {
    final db = await _dbHelper.database;
    return db.transaction((transaction) async {
      final deleted = await transaction.delete(
        'students',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (deleted > 0) {
        await transaction.insert('sync_queue', {
          'entity_type': 'student',
          'entity_id': id.toString(),
          'operation': 'delete',
          'payload': jsonEncode({'id': id}),
          'status': 'pending',
          'attempts': 0,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
      }
      return deleted;
    });
  }
}
