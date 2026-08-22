import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../../database/database_helper.dart';

class BackupService {
  /// تصدير نسخة احتياطية إلى المسار المحدد
  static Future<File> exportBackup(String destinationFolderPath) async {
    // إغلاق قاعدة البيانات لضمان عدم وجود عمليات كتابة معلقة
    await DatabaseHelper.instance.close();

    final dbDir = await getApplicationDocumentsDirectory();
    final dbPath = join(dbDir.path, 'school_secretariat.db');
    final dbFile = File(dbPath);

    if (!await dbFile.exists()) {
      throw Exception('قاعدة البيانات غير موجودة.');
    }

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final backupPath = join(destinationFolderPath, 'school_backup_$timestamp.db');

    return await dbFile.copy(backupPath);
  }

  /// استعادة نسخة احتياطية من ملف خارجي
  static Future<void> restoreBackup(String backupFilePath) async {
    final backupFile = File(backupFilePath);
    if (!await backupFile.exists()) {
      throw Exception('ملف النسخة الاحتياطية غير موجود.');
    }

    await DatabaseHelper.instance.close();

    final dbDir = await getApplicationDocumentsDirectory();
    final dbPath = join(dbDir.path, 'school_secretariat.db');

    // استبدال قاعدة البيانات الحالية بالنسخة الاحتياطية
    await backupFile.copy(dbPath);
  }
}