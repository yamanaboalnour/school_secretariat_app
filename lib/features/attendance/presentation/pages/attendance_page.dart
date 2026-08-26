import 'package:flutter/material.dart';

import '../../../students/data/models/student_model.dart';
import '../../../students/data/repositories/student_repository.dart';
import '../../data/models/attendance_record.dart';
import '../../data/repositories/attendance_repository.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final StudentRepository _studentRepository = StudentRepository();
  final AttendanceRepository _attendanceRepository = AttendanceRepository();
  final Map<int, AttendanceStatus> _statusByStudent = {};
  DateTime _selectedDate = DateTime.now();
  String _selectedGrade = '';
  List<StudentModel> _students = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  String get _dateKey => '${_selectedDate.year.toString().padLeft(4, '0')}-'
      '${_selectedDate.month.toString().padLeft(2, '0')}-'
      '${_selectedDate.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final students = await _studentRepository.getStudents();
      if (!mounted) return;
      setState(() {
        _students = students;
        _selectedGrade = students.isEmpty ? '' : students.first.gradeLevel;
        _isLoading = false;
      });
      await _loadExistingAttendance();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر تحميل الطلاب: $error';
      });
    }
  }

  Future<void> _loadExistingAttendance() async {
    if (_selectedGrade.isEmpty) return;
    final records = await _attendanceRepository.getByDateAndGrade(
      date: _dateKey,
      grade: _selectedGrade,
    );
    if (!mounted) return;
    setState(() {
      _statusByStudent
        ..clear()
        ..addEntries(
          records.map((record) => MapEntry(record.studentId, record.status)),
        );
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    setState(() => _selectedDate = date);
    await _loadExistingAttendance();
  }

  Future<void> _saveAttendance() async {
    final records = _filteredStudents
        .where((student) => student.id != null)
        .map(
          (student) => AttendanceRecord(
            studentId: student.id!,
            attendanceDate: _dateKey,
            status: _statusByStudent[student.id!] ?? AttendanceStatus.present,
          ),
        )
        .toList();
    setState(() => _isSaving = true);
    try {
      await _attendanceRepository.saveAll(records);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ سجل الحضور بنجاح.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل حفظ سجل الحضور: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  List<StudentModel> get _filteredStudents => _students
      .where((student) => student.gradeLevel == _selectedGrade)
      .toList();

  @override
  Widget build(BuildContext context) {
    final grades =
        _students.map((student) => student.gradeLevel).toSet().toList();
    return Scaffold(
      appBar: AppBar(title: const Text('الحضور والغياب')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedGrade.isEmpty
                                    ? null
                                    : _selectedGrade,
                                decoration: const InputDecoration(
                                  labelText: 'الصف',
                                  border: OutlineInputBorder(),
                                ),
                                items: grades
                                    .map((grade) => DropdownMenuItem(
                                          value: grade,
                                          child: Text(grade),
                                        ))
                                    .toList(),
                                onChanged: (grade) async {
                                  if (grade == null) return;
                                  setState(() => _selectedGrade = grade);
                                  await _loadExistingAttendance();
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_today),
                              label: Text(_dateKey),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _filteredStudents.isEmpty
                            ? const Center(
                                child: Text('لا يوجد طلاب في هذا الصف.'))
                            : ListView.builder(
                                itemCount: _filteredStudents.length,
                                itemBuilder: (context, index) {
                                  final student = _filteredStudents[index];
                                  final status = _statusByStudent[student.id] ??
                                      AttendanceStatus.present;
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    child: ListTile(
                                      title: Text(
                                          '${student.firstName} ${student.lastName}'),
                                      subtitle: Text(student.fatherName),
                                      trailing:
                                          DropdownButton<AttendanceStatus>(
                                        value: status,
                                        onChanged: (value) {
                                          if (value == null ||
                                              student.id == null) return;
                                          setState(() =>
                                              _statusByStudent[student.id!] =
                                                  value);
                                        },
                                        items: const [
                                          DropdownMenuItem(
                                            value: AttendanceStatus.present,
                                            child: Text('حاضر'),
                                          ),
                                          DropdownMenuItem(
                                            value: AttendanceStatus.absent,
                                            child: Text('غائب'),
                                          ),
                                          DropdownMenuItem(
                                            value: AttendanceStatus.excused,
                                            child: Text('بعذر'),
                                          ),
                                          DropdownMenuItem(
                                            value: AttendanceStatus.late,
                                            child: Text('متأخر'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
      bottomNavigationBar: _isLoading || _errorMessage != null
          ? null
          : Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _saveAttendance,
                icon: const Icon(Icons.save),
                label: Text(_isSaving ? 'جاري الحفظ...' : 'حفظ الحضور'),
              ),
            ),
    );
  }
}
