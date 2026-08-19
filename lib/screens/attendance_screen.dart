import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../models/attendance_model.dart';
import '../services/student_service.dart';
import '../services/attendance_service.dart';
import '../widgets/app_drawer.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final StudentService _studentService = StudentService();
  final AttendanceService _attendanceService = AttendanceService();

  DateTime _selectedDate = DateTime.now();
  String _selectedGrade = 'الأول الثانوي';
  
  // خريطة لتخزين حالة حضور كل طالب مؤقتًا قبل الحفظ
  final Map<String, AttendanceStatus> _attendanceStatusMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أمانة السر - الحضور والغياب اليومي'),
        backgroundColor: Colors.amber.shade800,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // شريط اختيار التاريخ والصف
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.amber.shade50,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGrade,
                    items: ['الأول الثانوي', 'الثاني الثانوي', 'الثالث الثانوي']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedGrade = val!),
                    decoration: const InputDecoration(
                      labelText: 'الصف الدراسي',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text("${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}"),
                ),
              ],
            ),
          ),
          
          // قائمة الطلاب لرصد الحضور
          Expanded(
            child: StreamBuilder<List<StudentModel>>(
              stream: _studentService.getStudentsByGrade(_selectedGrade),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('لا يوجد طلاب مسجلون في هذا الصف'));
                }

                final students = snapshot.data!;

                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final currentStatus = _attendanceStatusMap[student.id] ?? AttendanceStatus.present;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        title: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('الشعبة: ${student.section}'),
                        trailing: SegmentedButton<AttendanceStatus>(
                          segments: const [
                            ButtonSegment(
                              value: AttendanceStatus.present,
                              label: Text('حاضر'),
                              icon: Icon(Icons.check, color: Colors.green),
                            ),
                            ButtonSegment(
                              value: AttendanceStatus.absent,
                              label: Text('غائب'),
                              icon: Icon(Icons.close, color: Colors.red),
                            ),
                            ButtonSegment(
                              value: AttendanceStatus.excused,
                              label: Text('بعذر'),
                              icon: Icon(Icons.info_outline, color: Colors.orange),
                            ),
                          ],
                          selected: {currentStatus},
                          onSelectionChanged: (Set<AttendanceStatus> newSelection) {
                            setState(() {
                              _attendanceStatusMap[student.id] = newSelection.first;
                            });
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade800,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: _saveAttendance,
          icon: const Icon(Icons.save),
          label: const Text('حفظ سجل الحضور والغياب', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveAttendance() async {
    List<AttendanceModel> records = [];

    // جلب قائمة الطلاب الحالية لإنشاء السجلات
    final studentsSnapshot = await _studentService.getStudentsByGrade(_selectedGrade).first;

    for (var student in studentsSnapshot) {
      records.add(
        AttendanceModel(
          id: '',
          studentId: student.id,
          studentName: student.fullName,
          grade: student.grade,
          section: student.section,
          date: _selectedDate,
          status: _attendanceStatusMap[student.id] ?? AttendanceStatus.present,
        ),
      );
    }

    await _attendanceService.saveDailyAttendance(records);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ سجل الحضور والغياب بنجاح!'), backgroundColor: Colors.green),
      );
    }
  }
}