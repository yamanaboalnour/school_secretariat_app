import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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
      version: 5,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
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

    await _createSchoolProfileTable(db);
    await _createGradesTable(db);
    await _createUsersTable(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createSchoolProfileTable(db);
    }
    if (oldVersion < 3) {
      await _createGradesTable(db);
    }
    if (oldVersion < 4) {
      await _createUsersTable(db);
    }
    if (oldVersion < 5) {
      await _createSyncQueueTable(db);
    }
  }

  Future<void> _createSchoolProfileTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS school_profile (
        id INTEGER PRIMARY KEY,
        school_name TEXT NOT NULL,
        governorate TEXT NOT NULL,
        director_name TEXT NOT NULL,
        secretary_name TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createGradesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS grades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        subject_name TEXT NOT NULL,
        first_term REAL NOT NULL DEFAULT 0,
        second_term REAL NOT NULL DEFAULT 0,
        UNIQUE(student_id, subject_name),
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        full_name TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        salt TEXT NOT NULL,
        role TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<void> _createSyncQueueTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        payload TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        attempts INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_sync_queue_status_created
      ON sync_queue(status, created_at)
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
