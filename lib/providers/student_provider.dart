import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/db_service.dart';
import '../services/student_service.dart';

class StudentProvider with ChangeNotifier {
  List<Student> _students = [];
  bool _isLoading = false;

  List<Student> get students => _students;
  bool get isLoading => _isLoading;

  // تحميل البيانات من قاعدة البيانات المحلية (وتهجير بيانات الـ CSV إن كانت القاعدة فارغة)
  Future<void> fetchAndInitStudents() async {
    _isLoading = true;
    notifyListeners();

    _students = await DBService.getAllStudents();

    // إذا كانت قاعدة البيانات فارغة للمرة الأولى، نقرأ من الـ CSV ونحفظ في SQLite
    if (_students.isEmpty) {
      final csvStudents = await StudentService.loadStudentsFromCsv();
      for (var student in csvStudents) {
        await DBService.insertStudent(student);
      }
      _students = await DBService.getAllStudents();
    }

    _isLoading = false;
    notifyListeners();
  }

  // إضافة طالب جديد
  Future<void> addStudent(Student student) async {
    await DBService.insertStudent(student);
    _students.add(student);
    notifyListeners();
  }

  // تعديل بيانات طالب
  Future<void> updateStudent(Student student) async {
    await DBService.updateStudent(student);
    final index = _students.indexWhere((s) => s.generalId == student.generalId);
    if (index != -1) {
      _students[index] = student;
      notifyListeners();
    }
  }

  // حذف طالب
  Future<void> deleteStudent(String generalId) async {
    await DBService.deleteStudent(generalId);
    _students.removeWhere((s) => s.generalId == generalId);
    notifyListeners();
  }
}