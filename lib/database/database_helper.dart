import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('school_secretariat.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // دعم منصات سطح المكتب (Desktop Support)
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // جدول الطلاب الأساسي
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        father_name TEXT NOT NULL,
        mother_name TEXT NOT NULL,
        national_id TEXT UNIQUE,
        birth_date TEXT,
        grade_level TEXT NOT NULL,
        registration_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // جدول السجلات/المستندات الصادرة
    await db.execute('''
      CREATE TABLE issued_documents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        document_type TEXT NOT NULL,
        issue_date TEXT NOT NULL,
        file_path TEXT,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}