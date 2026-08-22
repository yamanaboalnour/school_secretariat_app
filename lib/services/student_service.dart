import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/student_model.dart';
import 'package:csv/csv.dart';

class StudentService {
  static Future<List<Student>> loadStudentsFromCsv() async {
    try {
      final rawData = await rootBundle.loadString('assets/students.csv');
List<List<dynamic>> listData = CsvToListConverter().convert(rawData);

      List<Student> students = [];
      // التجاوز عن السطر الأول (Header)
      for (int i = 1; i < listData.length; i++) {
        var row = listData[i];
        if (row.isEmpty || row.length < 2) continue;

        students.add(Student(
          generalId: row[0].toString(),
          fullName: row[1].toString(),
          fatherName: row.length > 2 ? row[2].toString() : '',
          motherName: row.length > 3 ? row[3].toString() : '',
          birthPlace: row.length > 4 ? row[4].toString() : '',
          birthDate: row.length > 5 ? row[5].toString() : '',
          latestGrade: row.length > 6 ? row[6].toString() : 'غير محدد',
          latestStatus: row.length > 7 ? row[7].toString() : 'مستجد',
          academicHistory: {},
        ));
      }
      return students;
    } catch (e) {
      print("Error loading CSV: $e");
      return [];
    }
  }
}