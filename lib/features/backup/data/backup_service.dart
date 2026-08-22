import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../../database/database_helper.dart';

class BackupService {
  static const _saltLength = 16;
  static const _pbkdf2Iterations = 120000;

  static Future<File> exportEncryptedBackup(
    String destinationFolderPath,
    String password,
  ) async {
    if (password.length < 8) {
      throw const FormatException('كلمة مرور النسخة يجب أن تكون 8 محارف على الأقل.');
    }
    final database = await DatabaseHelper.instance.database;
    final integrity = await database.rawQuery('PRAGMA integrity_check');
    if (integrity.isEmpty || integrity.first.values.first != 'ok') {
      throw Exception('فشل التحقق من سلامة قاعدة البيانات.');
    }
    await DatabaseHelper.instance.close();

    final dbDir = await getApplicationDocumentsDirectory();
    final dbFile = File(join(dbDir.path, 'school_secretariat.db'));
    if (!await dbFile.exists()) throw Exception('قاعدة البيانات غير موجودة.');

    final salt = _randomBytes(_saltLength);
    final key = await _deriveKey(password, salt);
    final box = await AesGcm.with256bits().encrypt(
      await dbFile.readAsBytes(),
      secretKey: key,
    );
    final encryptedBytes = Uint8List.fromList([
      ...salt,
      ...box.concatenation(),
    ]);

    final directory = Directory(destinationFolderPath);
    if (!await directory.exists()) await directory.create(recursive: true);
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File(join(destinationFolderPath, 'school_backup_$timestamp.db.enc'));
    return file.writeAsBytes(encryptedBytes, flush: true);
  }

  static Future<void> restoreEncryptedBackup(
    String backupFilePath,
    String password,
  ) async {
    if (password.length < 8) {
      throw const FormatException('كلمة مرور النسخة غير صالحة.');
    }
    final file = File(backupFilePath);
    final bytes = await file.readAsBytes();
    if (bytes.length <= _saltLength) throw const FormatException('النسخة المشفرة تالفة.');

    final salt = bytes.sublist(0, _saltLength);
    final box = SecretBox.fromConcatenation(
      bytes.sublist(_saltLength),
      nonceLength: 12,
      macLength: 16,
    );
    final key = await _deriveKey(password, salt);
    final plainBytes = await AesGcm.with256bits().decrypt(box, secretKey: key);

    await DatabaseHelper.instance.close();
    final dbDir = await getApplicationDocumentsDirectory();
    final dbPath = join(dbDir.path, 'school_secretariat.db');
    await File(dbPath).writeAsBytes(plainBytes, flush: true);
  }

  static List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }

  static Future<SecretKey> _deriveKey(String password, List<int> salt) {
    return Pbkdf2.hmacSha256(
      iterations: _pbkdf2Iterations,
      bits: 256,
    ).deriveKey(
      secretKey: SecretKey(password.codeUnits),
      nonce: salt,
    );
  }

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