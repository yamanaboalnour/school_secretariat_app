import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/student_service.dart';

class StudentProvider with ChangeNotifier {
  List<Student> _students = [];
  bool _isLoading = false;

  List<Student> get students => _students;
  bool get isLoading => _isLoading;

  // الدالة المطلوبة في main.dart
  Future<void> fetchAndInitStudents() async {
    await fetchStudents();
  }

  Future<void> fetchStudents() async {
    _isLoading = true;
    notifyListeners();

    try {
      _students = await StudentService.getStudents();
    } catch (e) {
      debugPrint('Error fetching students: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFromCsv() async {
    _isLoading = true;
    notifyListeners();

    try {
      final csvStudents = await StudentService.loadStudentsFromCsv();
      _students.addAll(csvStudents);
    } catch (e) {
      debugPrint('Error loading CSV: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addStudent(Student student) async {
    await StudentService.addStudent(student);
    _students.add(student);
    notifyListeners();
  }

  Future<void> updateStudent(Student student) async {
    await StudentService.updateStudent(student);
    final index = _students.indexWhere((s) => s.generalId == student.generalId);
    if (index != -1) {
      _students[index] = student;
      notifyListeners();
    }
  }

  // دعم نوع البيانات Dynamic لتفادي تعارض (String / int)
  Future<void> deleteStudent(dynamic id) async {
    await StudentService.deleteStudent(id);
    _students.removeWhere((s) => s.generalId == id);
    notifyListeners();
  }
}
