import 'package:flutter/material.dart';
import '../models/teacher_model.dart';
import '../services/teacher_service.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  final TeacherService _teacherService = TeacherService();

  final _nameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _classesController = TextEditingController();

  TeacherRole _selectedRole = TeacherRole.teacher;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أمانة السر - سجل المدرسين والكادر الإداري'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTeacherDialog,
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text('إضافة مدرس/إداري',
            style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<List<TeacherModel>>(
        stream: _teacherService.getAllTeachers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'لا يوجد أعضاء في الكادر التدريسي حالياً',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final teachers = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: teachers.length,
              itemBuilder: (context, index) {
                final teacher = teachers[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade100,
                      child: Text(
                        teacher.fullName.isNotEmpty ? teacher.fullName[0] : 'م',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                    ),
                    title: Text(
                      teacher.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'المادة: ${teacher.subject} | النصاب: ${teacher.weeklyClasses} حصة | الصلاحية: ${_getRoleName(teacher.role)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () =>
                          _teacherService.deleteTeacher(teacher.id),
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

  String _getRoleName(TeacherRole role) {
    switch (role) {
      case TeacherRole.admin:
        return 'مدير النظام';
      case TeacherRole.secretary:
        return 'أمين سر';
      case TeacherRole.teacher:
        return 'مدرس';
    }
  }

  void _showAddTeacherDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            const Text('إضافة عضو جديد بالكادر', textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'الاسم الكامل'),
              ),
              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'المادة / التخصص'),
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
              ),
              TextField(
                controller: _emailController,
                decoration:
                    const InputDecoration(labelText: 'البريد الإلكتروني'),
              ),
              TextField(
                controller: _classesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'عدد الحصص الأسبوعية (النصاب)'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<TeacherRole>(
                initialValue: _selectedRole,
                items: const [
                  DropdownMenuItem(
                      value: TeacherRole.teacher, child: Text('مدرس')),
                  DropdownMenuItem(
                      value: TeacherRole.secretary, child: Text('أمين سر')),
                  DropdownMenuItem(
                      value: TeacherRole.admin, child: Text('مدير نظام')),
                ],
                onChanged: (val) => setState(() => _selectedRole = val!),
                decoration:
                    const InputDecoration(labelText: 'الصلاحية (الدور)'),
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
                final newTeacher = TeacherModel(
                  id: '',
                  fullName: _nameController.text,
                  subject: _subjectController.text,
                  phone: _phoneController.text,
                  email: _emailController.text,
                  role: _selectedRole,
                  weeklyClasses: int.tryParse(_classesController.text) ?? 0,
                  createdAt: DateTime.now(),
                );

                await _teacherService.addTeacher(newTeacher);

                _nameController.clear();
                _subjectController.clear();
                _phoneController.clear();
                _emailController.clear();
                _classesController.clear();

                if (!mounted) return;
                Navigator.pop(this.context);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
