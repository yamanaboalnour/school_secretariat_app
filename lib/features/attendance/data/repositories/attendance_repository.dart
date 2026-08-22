import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../../database/database_helper.dart';
import '../models/attendance_record.dart';

class AttendanceRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<AttendanceRecord>> getByDateAndGrade({
    required String date,
    required String grade,
  }) async {
    final database = await _databaseHelper.database;
    final rows = await database.rawQuery('''
      SELECT a.*
      FROM attendance a
      INNER JOIN students s ON s.id = a.student_id
      WHERE a.attendance_date = ? AND s.grade_level = ?
      ORDER BY s.first_name COLLATE NOCASE, s.last_name COLLATE NOCASE
    ''', [date, grade]);
    return rows.map(AttendanceRecord.fromMap).toList();
  }

  Future<void> saveAll(List<AttendanceRecord> records) async {
    if (records.isEmpty) return;
    final database = await _databaseHelper.database;
    await database.transaction((transaction) async {
      for (final record in records) {
        final values = record.toMap()..remove('id');
        await transaction.insert(
          'attendance',
          {
            ...values,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await transaction.insert('sync_queue', {
          'entity_type': 'attendance',
          'entity_id': '${record.studentId}_${record.attendanceDate}',
          'operation': 'upsert',
          'payload': jsonEncode(values),
          'status': 'pending',
          'attempts': 0,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        });
      }
    });
  }
}
