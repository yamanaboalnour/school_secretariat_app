import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Students extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nationalId =>
      text().unique().nullable()(); // الرقم القومي/الوزاري
  TextColumn get firstName => text().withLength(min: 2, max: 50)();
  TextColumn get fatherName => text().withLength(min: 2, max: 50)();
  TextColumn get lastName => text().withLength(min: 2, max: 50)();
  TextColumn get motherName => text().withLength(min: 2, max: 50)();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get birthPlace => text().nullable()();
  // حقول معمارية Offline-First والمزامنة
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// تعريف جدول السجلات الدراسية
class AcademicRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get studentId => integer().references(Students, #id)();
  TextColumn get academicYear => text()(); // مثال: 2025/2026
  TextColumn get grade => text()(); // العاشر، الحادي عشر، الثاني عشر
  TextColumn get section => text().nullable()(); // الشعبة
  TextColumn get status => text()(); // ناجح، راسب، ثلاث سنوات، إلخ
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// تعريف جدول وثائق الأرشيف والـ QR
class DocumentLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get studentId => integer().references(Students, #id)();
  TextColumn get documentType =>
      text()(); // تسلسل دراسي، كارت طالب، وثيقة انتقال
  TextColumn get serialNumber => text().unique()();
  TextColumn get qrHash => text()(); // النص المشفر داخل QR
  IntColumn get issuedByUserId => integer()();
  DateTimeColumn get issuedAt => dateTime().withDefault(currentDateAndTime)();
}

// تعريف جدول المستخدمين والصلاحيات
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().unique()();
  TextColumn get passwordHash => text()();
  TextColumn get role => text()(); // ADMIN, SECRETARY
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

@DriftDatabase(tables: [Students, AcademicRecords, DocumentLogs, Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'school_db.sqlite'));
    return NativeDatabase(file);
  });
}
