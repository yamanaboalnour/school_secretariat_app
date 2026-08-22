import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/student_model.dart';

class DBService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'school_secretariat.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // جدول الطلاب
        await db.execute('''
          CREATE TABLE students (
            generalId TEXT PRIMARY KEY,
            fullName TEXT NOT NULL,
            fatherName TEXT,
            motherName TEXT,
            birthPlace TEXT,
            birthDate TEXT,
            latestGrade TEXT,
            latestStatus TEXT,
            isSynced INTEGER DEFAULT 0
          )
        ''');

        // جدول سجل التسلسلات
        await db.execute('''
          CREATE TABLE sequence_logs (
            id TEXT PRIMARY KEY,
            studentName TEXT NOT NULL,
            generalId TEXT NOT NULL,
            generatedAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // --- عمليات الطلاب (CRUD) ---

  static Future<int> insertStudent(Student student) async {
    final db = await database;
    return await db.insert(
      'students',
      student.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Student>> getAllStudents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('students');
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  static Future<int> updateStudent(Student student) async {
    final db = await database;
    return await db.update(
      'students',
      student.toMap(),
      where: 'generalId = ?',
      whereArgs: [student.generalId],
    );
  }

  static Future<int> deleteStudent(String generalId) async {
    final db = await database;
    return await db.delete(
      'students',
      where: 'generalId = ?',
      whereArgs: [generalId],
    );
  }
}