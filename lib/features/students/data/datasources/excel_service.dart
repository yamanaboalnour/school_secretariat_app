import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../models/student_model.dart';

class ExcelService {
  static Future<bool> exportStudentsToExcel(
    List<StudentModel> students,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Students'];
    sheet.appendRow([
      TextCellValue('الاسم الأول'),
      TextCellValue('الكنية'),
      TextCellValue('اسم الأب'),
      TextCellValue('اسم الأم'),
      TextCellValue('الرقم الوطني'),
      TextCellValue('الصف'),
      TextCellValue('تاريخ الميلاد'),
    ]);

    for (final student in students) {
      sheet.appendRow([
        TextCellValue(student.firstName),
        TextCellValue(student.lastName),
        TextCellValue(student.fatherName),
        TextCellValue(student.motherName),
        TextCellValue(student.nationalId ?? ''),
        TextCellValue(student.gradeLevel),
        TextCellValue(student.birthDate ?? ''),
      ]);
    }

    final bytes = excel.save();
    if (bytes == null || bytes.isEmpty) {
      return false;
    }

    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'تصدير قائمة الطلاب',
      fileName: 'students.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      bytes: Uint8List.fromList(bytes),
    );
    return path != null;
  }

  /// اختيار واستيراد طلاب من ملف إكسل
  static Future<List<StudentModel>> importStudentsFromExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result == null || result.files.single.path == null) {
      return [];
    }

    final bytes = File(result.files.single.path!).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    List<StudentModel> importedStudents = [];

    for (var table in excel.tables.keys) {
      final rows = excel.tables[table]?.rows;
      if (rows == null || rows.isEmpty) continue;

      // التجاوز عن صف الهيدر (العناوين)
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty || _cellText(row[0]).trim().isEmpty) continue;

        importedStudents.add(
          StudentModel(
            firstName: _cellTextAt(row, 0),
            lastName: _cellTextAt(row, 1),
            fatherName: _cellTextAt(row, 2),
            motherName: _cellTextAt(row, 3),
            nationalId: _optionalCellTextAt(row, 4),
            birthDate: _optionalCellTextAt(row, 6),
            gradeLevel: _cellTextAt(row, 5, fallback: 'غير محدد'),
            registrationDate: DateTime.now().toIso8601String(),
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
      }
    }

    return importedStudents;
  }

  static String _cellTextAt(
    List<Data?> row,
    int index, {
    String fallback = '',
  }) {
    if (index >= row.length) return fallback;
    final value = _cellText(row[index]).trim();
    return value.isEmpty ? fallback : value;
  }

  static String? _optionalCellTextAt(List<Data?> row, int index) {
    final value = _cellTextAt(row, index);
    return value.isEmpty ? null : value;
  }

  static String _cellText(Data? cell) {
    final value = cell?.value;
    if (value == null) return '';
    if (value is TextCellValue) return value.value.text ?? '';
    if (value is IntCellValue) return value.value.toString();
    if (value is DoubleCellValue) return value.value.toString();
    if (value is BoolCellValue) return value.value.toString();
    if (value is DateTimeCellValue) {
      return value.asDateTimeLocal().toIso8601String();
    }
    return value.toString();
  }
}