import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

import '../models/academic_sequence_model.dart';

class AcademicSequenceCsvService {
  // غيّر اسم الملف إذا كان اسم ملفك الحقيقي مختلفًا.
  static const String studentsAsset = 'assets/students/students.csv';

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

    // السجل العام للطلاب اختياري في حال كان فارغًا.
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
      // نتابع من ملف النتائج الدراسية.
    }

    final history = _buildHistoryIndex(
      historyRows,
    );

    final result = <AcademicStudent>[];

    for (final item in history.values) {
      final student = students[item.studentNumber];

      result.add(
        AcademicStudent(
          studentNumber: item.studentNumber,
          firstName: _prefer(
            student?['firstName'],
            item.firstName,
          ),
          lastName: _prefer(
            student?['lastName'],
            item.lastName,
          ),
          fatherName: _prefer(
            student?['fatherName'],
            item.fatherName,
          ),
          birthPlace: _prefer(
            student?['birthPlace'],
            item.birthPlace,
          ),
          birthDate: _prefer(
            student?['birthDate'],
            item.birthDate,
          ),
          currentGrade: _gradeName(
            _prefer(
              student?['grade'],
              item.currentGrade,
            ),
          ),
          section: _prefer(
            student?['section'],
            item.section,
          ),
          records: item.records,
        ),
      );
    }

    result.sort(
      (a, b) {
        final aNumber = int.tryParse(a.studentNumber);

        final bNumber = int.tryParse(b.studentNumber);

        if (aNumber != null && bNumber != null) {
          return aNumber.compareTo(
            bNumber,
          );
        }

        return a.studentNumber.compareTo(
          b.studentNumber,
        );
      },
    );

    return result;
  }

  String _prefer(
    String? preferred,
    String fallback,
  ) {
    if (preferred != null && preferred.trim().isNotEmpty) {
      return preferred.trim();
    }

    return fallback.trim();
  }

  List<List<dynamic>> _parse(
    String source,
  ) {
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

    final headers = rows.first
        .map(
          (e) => e.toString().trim(),
        )
        .toList();

    final numberIndex = _findColumn(
      headers,
      const [
        'NoStudents',
        'NoStudent',
        'رقم الطالب',
        'رقم الطالب الوطني',
        'الرقم',
      ],
    );

    if (numberIndex == -1) {
      return {};
    }

    final firstNameIndex = _findColumn(
      headers,
      const [
        'اسم الطالب',
        'الاسم الأول',
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
        'اللقب',
        'lastName',
        'LastName',
        'surname',
      ],
    );

    final fatherNameIndex = _findColumn(
      headers,
      const [
        'اسم الأب',
        'اسم الاب',
        'الأب',
        'fatherName',
        'FatherName',
        'father_name',
      ],
    );

    final birthPlaceIndex = _findColumn(
      headers,
      const [
        'مكان الولادة',
        'مكان التولد',
        'مكان الميلاد',
        'birthPlace',
        'BirthPlace',
        'birth_place',
      ],
    );

    final birthDateIndex = _findColumn(
      headers,
      const [
        'تاريخ الولادة',
        'تاريخ التولد',
        'تاريخ الميلاد',
        'birthDate',
        'BirthDate',
        'birth_date',
      ],
    );

    final gradeIndex = _findColumn(
      headers,
      const [
        'الصف',
        'المرحلة',
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
      final number = _value(
        row,
        numberIndex,
      );

      if (number.isEmpty) {
        continue;
      }

      result[number] = {
        'firstName': _value(
          row,
          firstNameIndex,
        ),
        'lastName': _value(
          row,
          lastNameIndex,
        ),
        'fatherName': _value(
          row,
          fatherNameIndex,
        ),
        'birthPlace': _value(
          row,
          birthPlaceIndex,
        ),
        'birthDate': _value(
          row,
          birthDateIndex,
        ),
        'grade': _value(
          row,
          gradeIndex,
        ),
        'section': _value(
          row,
          sectionIndex,
        ),
      };
    }

    return result;
  }

  Map<String, _HistoryStudent> _buildHistoryIndex(
    List<List<dynamic>> rows,
  ) {
    final headers = rows.first
        .map(
          (e) => e.toString().trim(),
        )
        .toList();

    final numberIndex = _findColumn(
      headers,
      const [
        'NoStudents',
        'NoStudent',
        'رقم الطالب',
        'الرقم',
      ],
    );

    if (numberIndex == -1) {
      throw Exception(
        'لم يتم العثور على رقم الطالب في ملف النتائج.',
      );
    }

    final firstNameIndex = _findColumn(
      headers,
      const [
        'اسم الطالب',
        'الاسم الأول',
        'الاسم',
      ],
    );

    final lastNameIndex = _findColumn(
      headers,
      const [
        'كنية الطالب',
        'الكنية',
        'اللقب',
      ],
    );

    final fatherNameIndex = _findColumn(
      headers,
      const [
        'اسم الأب',
        'اسم الاب',
        'الأب',
      ],
    );

    final birthPlaceIndex = _findColumn(
      headers,
      const [
        'مكان الولادة',
        'مكان التولد',
        'مكان الميلاد',
      ],
    );

    final birthDateIndex = _findColumn(
      headers,
      const [
        'تاريخ الولادة',
        'تاريخ التولد',
        'تاريخ الميلاد',
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

    final yearColumns = <int, String>{};

    for (var i = 0; i < headers.length; i++) {
      final header = headers[i];

      if (RegExp(
        r'^\d{4}-\d{4}$',
      ).hasMatch(header)) {
        yearColumns[i] = header;
      }
    }

    if (yearColumns.isEmpty) {
      throw Exception(
        'لم يتم العثور على السنوات الدراسية.',
      );
    }

    final result = <String, _HistoryStudent>{};

    for (final row in rows.skip(1)) {
      final number = _value(
        row,
        numberIndex,
      );

      if (number.isEmpty) {
        continue;
      }

      final records = <AcademicYearRecord>[];

      for (final entry in yearColumns.entries) {
        final raw = _value(
          row,
          entry.key,
        );

        if (raw.isEmpty) {
          continue;
        }

        final parsed = _parseResult(raw);

        records.add(
          AcademicYearRecord(
            academicYear: entry.value,
            grade: _gradeName(
              parsed.grade,
            ),
            status: parsed.status,
            rawValue: raw,
          ),
        );
      }

      result[number] = _HistoryStudent(
        studentNumber: number,
        firstName: _value(
          row,
          firstNameIndex,
        ),
        lastName: _value(
          row,
          lastNameIndex,
        ),
        fatherName: _value(
          row,
          fatherNameIndex,
        ),
        birthPlace: _value(
          row,
          birthPlaceIndex,
        ),
        birthDate: _value(
          row,
          birthDateIndex,
        ),
        currentGrade: _gradeName(
          _value(
            row,
            gradeIndex,
          ),
        ),
        section: _value(
          row,
          sectionIndex,
        ),
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
      status: value
          .substring(
            0,
            separatorIndex,
          )
          .trim(),
      grade: value
          .substring(
            separatorIndex + 1,
          )
          .trim(),
    );
  }

  String _gradeName(
    String value,
  ) {
    switch (value.trim()) {
      case '7':
      case 'السابع':
        return 'السابع';

      case '8':
      case 'الثامن':
        return 'الثامن';

      case '9':
      case 'التاسع':
        return 'التاسع';

      case '10':
      case 'العاشر':
        return 'العاشر';

      case '11':
      case 'الحادي عشر':
        return 'الحادي عشر';

      case '12':
      case 'الثاني عشر':
      case 'البكالوريا':
      case 'الباكلوريا':
        return 'الباكلوريا';

      default:
        return value.trim();
    }
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
  final String fatherName;
  final String birthPlace;
  final String birthDate;
  final String currentGrade;
  final String section;
  final List<AcademicYearRecord> records;

  const _HistoryStudent({
    required this.studentNumber,
    required this.firstName,
    required this.lastName,
    required this.fatherName,
    required this.birthPlace,
    required this.birthDate,
    required this.currentGrade,
    required this.section,
    required this.records,
  });
}
