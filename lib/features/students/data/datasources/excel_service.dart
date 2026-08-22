import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../models/student_model.dart';

class ExcelService {
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
        if (row.isEmpty || row[0] == null) continue;

        importedStudents.add(
          StudentModel(
            firstName: row[0]?.value?.toString() ?? '',
            lastName: row[1]?.value?.toString() ?? '',
            fatherName: row[2]?.value?.toString() ?? '',
            motherName: row[3]?.value?.toString() ?? '',
            nationalId: row[4]?.value?.toString(),
            gradeLevel: row[5]?.value?.toString() ?? 'غير محدد',
            registrationDate: DateTime.now().toIso8601String(),
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
      }
    }

    return importedStudents;
  }
}