import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

import '../models/academic_sequence_model.dart';

class AcademicSequenceCsvService {
  static const String studentsAsset = 'assets/students.csv';

  static const String academicHistoryAsset =
      'assets/Record the results of the years for students.csv';

  Future<List<AcademicStudent>> loadStudents() async {
    final historyCsv = await rootBundle.loadString(
      academicHistoryAsset,
    );

    final historyRows = _parse(historyCsv);

    if (historyRows.length < 2) {
      throw Exception(
        'ملف النتائج الدراسية فارغ أو لا يحتوي على بيانات.',
      );
    }

    Map<String, Map<String, String>> students = {};

    // students.csv اختياري حاليًا.
    // إذا كان الملف فارغًا أو غير صالح، نكمل من ملف النتائج.
    try {
      final studentsCsv = await rootBundle.loadString(
        studentsAsset,
      );

      if (studentsCsv.trim().isNotEmpty) {
        final studentRows = _parse(studentsCsv);

        if (studentRows.length >= 2) {
          students = _buildStudentIndex(studentRows);
        }
      }
    } catch (_) {
      // تجاهل الخطأ مؤقتًا والاعتماد على ملف النتائج.
    }

    final history = _buildHistoryIndex(historyRows);

    final result = <AcademicStudent>[];

    for (final item in history.values) {
      final student = students[item.studentNumber];

      final firstName = student?['firstName']?.trim().isNotEmpty == true
          ? student!['firstName']!
          : item.firstName;

      final lastName = student?['lastName']?.trim().isNotEmpty == true
          ? student!['lastName']!
          : item.lastName;

      final currentGrade = student?['grade']?.trim().isNotEmpty == true
          ? student!['grade']!
          : item.currentGrade;

      final section = student?['section']?.trim().isNotEmpty == true
          ? student!['section']!
          : item.section;

      result.add(
        AcademicStudent(
          studentNumber: item.studentNumber,
          firstName: firstName,
          lastName: lastName,
          currentGrade: currentGrade,
          section: section,
          records: item.records,
        ),
      );
    }

    result.sort((a, b) {
      final aNumber = int.tryParse(a.studentNumber);
      final bNumber = int.tryParse(b.studentNumber);

      if (aNumber != null && bNumber != null) {
        return aNumber.compareTo(bNumber);
      }

      return a.studentNumber.compareTo(b.studentNumber);
    });

    return result;
  }

  List<List<dynamic>> _parse(String source) {
    final normalized = source
        .replaceFirst('\uFEFF', '')
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');

    return const CsvToListConverter(
      fieldDelimiter: ';',
      shouldParseNumbers: false,
      eol: '\n',
    ).convert(normalized);
  }

  Map<String, Map<String, String>> _buildStudentIndex(
    List<List<dynamic>> rows,
  ) {
    if (rows.length < 2) {
      return {};
    }

    final headers = rows.first.map((e) => e.toString().trim()).toList();

    final numberIndex = _findColumn(
      headers,
      const [
        'NoStudents',
        'NoStudent',
        'رقم الطالب',
        'رقم',
      ],
    );

    if (numberIndex == -1) {
      return {};
    }

    final firstNameIndex = _findColumn(
      headers,
      const [
        'اسم الطالب',
        'الاسم',
        'firstName',
        'FirstName',
      ],
    );

    final lastNameIndex = _findColumn(
      headers,
      const [
        'كنية الطالب',
        'الكنية',
        'lastName',
        'LastName',
        'surname',
      ],
    );

    final gradeIndex = _findColumn(
      headers,
      const [
        'الصف',
        'grade',
        'grade_level',
      ],
    );

    final sectionIndex = _findColumn(
      headers,
      const [
        'الشعبة',
        'section',
      ],
    );

    final result = <String, Map<String, String>>{};

    for (final row in rows.skip(1)) {
      final number = _value(row, numberIndex);

      if (number.isEmpty) {
        continue;
      }

      result[number] = {
        'firstName': _value(row, firstNameIndex),
        'lastName': _value(row, lastNameIndex),
        'grade': _value(row, gradeIndex),
        'section': _value(row, sectionIndex),
      };
    }

    return result;
  }

  Map<String, _HistoryStudent> _buildHistoryIndex(
    List<List<dynamic>> rows,
  ) {
    final headers = rows.first.map((e) => e.toString().trim()).toList();

    final numberIndex = _findColumn(
      headers,
      const [
        'NoStudents',
        'NoStudent',
        'رقم الطالب',
      ],
    );

    final firstNameIndex = _findColumn(
      headers,
      const [
        'اسم الطالب',
        'الاسم',
      ],
    );

    final lastNameIndex = _findColumn(
      headers,
      const [
        'كنية الطالب',
        'الكنية',
      ],
    );

    final gradeIndex = _findColumn(
      headers,
      const [
        'الصف',
      ],
    );

    final sectionIndex = _findColumn(
      headers,
      const [
        'الشعبة',
      ],
    );

    if (numberIndex == -1) {
      throw Exception(
        'لم يتم العثور على عمود NoStudents في ملف النتائج الدراسية.',
      );
    }

    final yearColumns = <int, String>{};

    for (var i = 0; i < headers.length; i++) {
      final header = headers[i];

      if (RegExp(r'^\d{4}-\d{4}$').hasMatch(header)) {
        yearColumns[i] = header;
      }
    }

    if (yearColumns.isEmpty) {
      throw Exception(
        'لم يتم العثور على أعمدة السنوات الدراسية.',
      );
    }

    final result = <String, _HistoryStudent>{};

    for (final row in rows.skip(1)) {
      final number = _value(row, numberIndex);

      if (number.isEmpty) {
        continue;
      }

      final records = <AcademicYearRecord>[];

      for (final entry in yearColumns.entries) {
        final raw = _value(row, entry.key);

        if (raw.isEmpty) {
          continue;
        }

        final parsed = _parseResult(raw);

        records.add(
          AcademicYearRecord(
            academicYear: entry.value,
            grade: parsed.grade,
            status: parsed.status,
            rawValue: raw,
          ),
        );
      }

      result[number] = _HistoryStudent(
        studentNumber: number,
        firstName: _value(row, firstNameIndex),
        lastName: _value(row, lastNameIndex),
        currentGrade: _value(row, gradeIndex),
        section: _value(row, sectionIndex),
        records: records,
      );
    }

    return result;
  }

  ({String status, String grade}) _parseResult(
    String value,
  ) {
    final separatorIndex = value.lastIndexOf('/');

    if (separatorIndex == -1) {
      return (
        status: value.trim(),
        grade: '',
      );
    }

    return (
      status: value.substring(0, separatorIndex).trim(),
      grade: value.substring(separatorIndex + 1).trim(),
    );
  }

  int _findColumn(
    List<String> headers,
    List<String> candidates,
  ) {
    for (final candidate in candidates) {
      final index = headers.indexWhere(
        (header) =>
            header.trim().toLowerCase() == candidate.trim().toLowerCase(),
      );

      if (index != -1) {
        return index;
      }
    }

    return -1;
  }

  String _value(
    List<dynamic> row,
    int index,
  ) {
    if (index < 0 || index >= row.length) {
      return '';
    }

    return row[index].toString().trim();
  }
}

class _HistoryStudent {
  final String studentNumber;
  final String firstName;
  final String lastName;
  final String currentGrade;
  final String section;
  final List<AcademicYearRecord> records;

  const _HistoryStudent({
    required this.studentNumber,
    required this.firstName,
    required this.lastName,
    required this.currentGrade,
    required this.section,
    required this.records,
  });
}
