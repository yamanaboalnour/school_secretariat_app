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

    final integrity = await DatabaseHelper.instance.database.then(
      (database) => database.rawQuery('PRAGMA integrity_check'),
    );
    if (integrity.isEmpty || integrity.first.values.first != 'ok') {
      throw Exception('فشل التحقق من سلامة قاعدة البيانات.');
    }

    final destinationDirectory = Directory(destinationFolderPath);
    if (!await destinationDirectory.exists()) {
      await destinationDirectory.create(recursive: true);
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

    if (backupFile.lengthSync() == 0) {
      throw Exception('ملف النسخة الاحتياطية فارغ.');
    }

    await DatabaseHelper.instance.close();

    final dbDir = await getApplicationDocumentsDirectory();
    final dbPath = join(dbDir.path, 'school_secretariat.db');

    // استبدال قاعدة البيانات الحالية بالنسخة الاحتياطية
    await backupFile.copy(dbPath);
  }
}