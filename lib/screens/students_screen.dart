import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/student_service.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final StudentService _studentService = StudentService();

  // حقول إدخال الطالب الجديد
  final _nameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  
  String _selectedGrade = 'الأول الثانوي';
  String _selectedBranch = 'عام';
  String _selectedSection = '1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أمانة السر - سجل الطلاب'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStudentDialog,
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('إضافة طالب', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<List<StudentModel>>(
        stream: _studentService.getAllStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'لا يوجد طلاب مسجلون حالياً',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final students = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade100,
                      child: Text(
                        student.fullName.isNotEmpty ? student.fullName[0] : 'ط',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                    ),
                    title: Text(
                      student.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${student.grade} - الشعبة: ${student.section} (${student.branch}) | السجل: ${student.nationalId}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _studentService.deleteStudent(student.id),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // نافذة إضافة طالب جديد
  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة طالب جديد إلى أمانة السر', textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'الاسم الكامل'),
              ),
              TextField(
                controller: _nationalIdController,
                decoration: const InputDecoration(labelText: 'الرقم الوطني / رقم التسجيل'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedGrade,
                items: ['الأول الثانوي', 'الثاني الثانوي', 'الثالث الثانوي']
                    .map((grade) => DropdownMenuItem(value: grade, child: Text(grade)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedGrade = val!),
                decoration: const InputDecoration(labelText: 'الصف الدراسي'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedBranch,
                items: ['عام', 'علمي', 'أدبي']
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedBranch = val!),
                decoration: const InputDecoration(labelText: 'الفرع'),
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'رقم هاتف الطالب'),
              ),
              TextField(
                controller: _guardianPhoneController,
                decoration: const InputDecoration(labelText: 'رقم هاتف ولي الأمر'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty) {
                final newStudent = StudentModel(
                  id: '',
                  fullName: _nameController.text,
                  nationalId: _nationalIdController.text,
                  grade: _selectedGrade,
                  section: _selectedSection,
                  branch: _selectedBranch,
                  phone: _phoneController.text,
                  guardianPhone: _guardianPhoneController.text,
                  createdAt: DateTime.now(),
                );

                await _studentService.addStudent(newStudent);

                _nameController.clear();
                _nationalIdController.clear();
                _phoneController.clear();
                _guardianPhoneController.clear();

                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}